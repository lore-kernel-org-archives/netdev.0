From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 08/21] Use standard indentation for definition of
 struct option args
Date: Tue, 1 Nov 2011 23:15:32 +0000
Message-ID: <1320189332.2758.38.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37985 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986Ab1KAXPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:15:36 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also put the whole of the help string on a line of its own where
necessary.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  280 +++++++++++++++++++++++++++++++------------------------------
 1 files changed, 142 insertions(+), 138 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index aab1e41..f967f84 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -140,145 +140,149 @@ static enum {
 } mode = MODE_GSET;
 
 static struct option {
-    char *srt, *lng;
-    int Mode;
-    char *help;
-    char *opthelp;
+	char *srt, *lng;
+	int Mode;
+	char *help;
+	char *opthelp;
 } args[] = {
-    { "-s", "--change", MODE_SSET, "Change generic options",
-		"		[ speed %d ]\n"
-		"		[ duplex half|full ]\n"
-		"		[ port tp|aui|bnc|mii|fibre ]\n"
-		"		[ autoneg on|off ]\n"
-		"		[ advertise %x ]\n"
-		"		[ phyad %d ]\n"
-		"		[ xcvr internal|external ]\n"
-		"		[ wol p|u|m|b|a|g|s|d... ]\n"
-		"		[ sopass %x:%x:%x:%x:%x:%x ]\n"
-		"		[ msglvl %d | msglvl type on|off ... ]\n" },
-    { "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
-    { "-A", "--pause", MODE_SPAUSE, "Set pause options",
-      "		[ autoneg on|off ]\n"
-      "		[ rx on|off ]\n"
-      "		[ tx on|off ]\n" },
-    { "-c", "--show-coalesce", MODE_GCOALESCE, "Show coalesce options" },
-    { "-C", "--coalesce", MODE_SCOALESCE, "Set coalesce options",
-		"		[adaptive-rx on|off]\n"
-		"		[adaptive-tx on|off]\n"
-		"		[rx-usecs N]\n"
-		"		[rx-frames N]\n"
-		"		[rx-usecs-irq N]\n"
-		"		[rx-frames-irq N]\n"
-		"		[tx-usecs N]\n"
-		"		[tx-frames N]\n"
-		"		[tx-usecs-irq N]\n"
-		"		[tx-frames-irq N]\n"
-		"		[stats-block-usecs N]\n"
-		"		[pkt-rate-low N]\n"
-		"		[rx-usecs-low N]\n"
-		"		[rx-frames-low N]\n"
-		"		[tx-usecs-low N]\n"
-		"		[tx-frames-low N]\n"
-		"		[pkt-rate-high N]\n"
-		"		[rx-usecs-high N]\n"
-		"		[rx-frames-high N]\n"
-		"		[tx-usecs-high N]\n"
-		"		[tx-frames-high N]\n"
-	        "		[sample-interval N]\n" },
-    { "-g", "--show-ring", MODE_GRING, "Query RX/TX ring parameters" },
-    { "-G", "--set-ring", MODE_SRING, "Set RX/TX ring parameters",
-		"		[ rx N ]\n"
-		"		[ rx-mini N ]\n"
-		"		[ rx-jumbo N ]\n"
-	        "		[ tx N ]\n" },
-    { "-k", "--show-offload", MODE_GOFFLOAD, "Get protocol offload information" },
-    { "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload",
-		"		[ rx on|off ]\n"
-		"		[ tx on|off ]\n"
-		"		[ sg on|off ]\n"
-	        "		[ tso on|off ]\n"
-	        "		[ ufo on|off ]\n"
-		"		[ gso on|off ]\n"
-		"		[ gro on|off ]\n"
-		"		[ lro on|off ]\n"
-		"		[ rxvlan on|off ]\n"
-		"		[ txvlan on|off ]\n"
-		"		[ ntuple on|off ]\n"
-		"		[ rxhash on|off ]\n"
-    },
-    { "-i", "--driver", MODE_GDRV, "Show driver information" },
-    { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
-		"		[ raw on|off ]\n"
-		"		[ file FILENAME ]\n" },
-    { "-e", "--eeprom-dump", MODE_GEEPROM, "Do a EEPROM dump",
-		"		[ raw on|off ]\n"
-		"		[ offset N ]\n"
-		"		[ length N ]\n" },
-    { "-E", "--change-eeprom", MODE_SEEPROM, "Change bytes in device EEPROM",
-		"		[ magic N ]\n"
-		"		[ offset N ]\n"
-		"		[ length N ]\n"
-		"		[ value N ]\n" },
-    { "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotiation" },
-    { "-p", "--identify", MODE_PHYS_ID, "Show visible port identification (e.g. blinking)",
-                "               [ TIME-IN-SECONDS ]\n" },
-    { "-t", "--test", MODE_TEST, "Execute adapter self test",
-		"               [ online | offline | external_lb ]\n" },
-    { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
-    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
-		"options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-		"tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-    { "-f", "--flash", MODE_FLASHDEV, "Flash firmware image "
-    		"from the specified file to a region on the device",
-		"               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-    { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
-		"classification options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-		"tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
-    { "-x", "--show-rxfh-indir", MODE_GRXFHINDIR, "Show Rx flow hash "
-		"indirection" },
-    { "-X", "--set-rxfh-indir", MODE_SRXFHINDIR, "Set Rx flow hash indirection",
-		"		equal N | weight W0 W1 ...\n" },
-    { "-U", "--config-ntuple", MODE_SCLSRULE, "Configure Rx ntuple filters "
-		"and actions",
-		"		[ delete %d ] |\n"
-		"		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
-		"			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
-		"			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
-		"			[ proto %d [m %x] ]\n"
-		"			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
-		"			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
-		"			[ tos %d [m %x] ]\n"
-		"			[ l4proto %d [m %x] ]\n"
-		"			[ src-port %d [m %x] ]\n"
-		"			[ dst-port %d [m %x] ]\n"
-		"			[ spi %d [m %x] ]\n"
-		"			[ vlan-etype %x [m %x] ]\n"
-		"			[ vlan %x [m %x] ]\n"
-		"			[ user-def %x [m %x] ]\n"
-		"			[ action %d ]\n"
-		"			[ loc %d]]\n" },
-    { "-u", "--show-ntuple", MODE_GCLSRULE,
-		"Get Rx ntuple filters and actions",
-		"		[ rule %d ]\n"},
-    { "-P", "--show-permaddr", MODE_PERMADDR,
-		"Show permanent hardware address" },
-    { "-w", "--get-dump", MODE_GET_DUMP,
-		"Get dump flag, data",
-		"		[ data FILENAME ]\n" },
-    { "-W", "--set-dump", MODE_SET_DUMP,
-		"Set dump flag of the device",
-		"		N\n"},
-    { "-l", "--show-channels", MODE_GCHANNELS, "Query Channels" },
-    { "-L", "--set-channels", MODE_SCHANNELS, "Set Channels",
-		"               [ rx N ]\n"
-		"               [ tx N ]\n"
-		"               [ other N ]\n"
-		"               [ combined N ]\n" },
-    { "-h", "--help", MODE_HELP, "Show this help" },
-    { NULL, "--version", MODE_VERSION, "Show version number" },
-    {}
+	{ "-s", "--change", MODE_SSET, "Change generic options",
+	  "		[ speed %d ]\n"
+	  "		[ duplex half|full ]\n"
+	  "		[ port tp|aui|bnc|mii|fibre ]\n"
+	  "		[ autoneg on|off ]\n"
+	  "		[ advertise %x ]\n"
+	  "		[ phyad %d ]\n"
+	  "		[ xcvr internal|external ]\n"
+	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
+	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
+	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
+	{ "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
+	{ "-A", "--pause", MODE_SPAUSE, "Set pause options",
+	  "		[ autoneg on|off ]\n"
+	  "		[ rx on|off ]\n"
+	  "		[ tx on|off ]\n" },
+	{ "-c", "--show-coalesce", MODE_GCOALESCE, "Show coalesce options" },
+	{ "-C", "--coalesce", MODE_SCOALESCE, "Set coalesce options",
+	  "		[adaptive-rx on|off]\n"
+	  "		[adaptive-tx on|off]\n"
+	  "		[rx-usecs N]\n"
+	  "		[rx-frames N]\n"
+	  "		[rx-usecs-irq N]\n"
+	  "		[rx-frames-irq N]\n"
+	  "		[tx-usecs N]\n"
+	  "		[tx-frames N]\n"
+	  "		[tx-usecs-irq N]\n"
+	  "		[tx-frames-irq N]\n"
+	  "		[stats-block-usecs N]\n"
+	  "		[pkt-rate-low N]\n"
+	  "		[rx-usecs-low N]\n"
+	  "		[rx-frames-low N]\n"
+	  "		[tx-usecs-low N]\n"
+	  "		[tx-frames-low N]\n"
+	  "		[pkt-rate-high N]\n"
+	  "		[rx-usecs-high N]\n"
+	  "		[rx-frames-high N]\n"
+	  "		[tx-usecs-high N]\n"
+	  "		[tx-frames-high N]\n"
+	  "		[sample-interval N]\n" },
+	{ "-g", "--show-ring", MODE_GRING, "Query RX/TX ring parameters" },
+	{ "-G", "--set-ring", MODE_SRING, "Set RX/TX ring parameters",
+	  "		[ rx N ]\n"
+	  "		[ rx-mini N ]\n"
+	  "		[ rx-jumbo N ]\n"
+	  "		[ tx N ]\n" },
+	{ "-k", "--show-offload", MODE_GOFFLOAD,
+	  "Get protocol offload information" },
+	{ "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload",
+	  "		[ rx on|off ]\n"
+	  "		[ tx on|off ]\n"
+	  "		[ sg on|off ]\n"
+	  "		[ tso on|off ]\n"
+	  "		[ ufo on|off ]\n"
+	  "		[ gso on|off ]\n"
+	  "		[ gro on|off ]\n"
+	  "		[ lro on|off ]\n"
+	  "		[ rxvlan on|off ]\n"
+	  "		[ txvlan on|off ]\n"
+	  "		[ ntuple on|off ]\n"
+	  "		[ rxhash on|off ]\n"
+	},
+	{ "-i", "--driver", MODE_GDRV, "Show driver information" },
+	{ "-d", "--register-dump", MODE_GREGS, "Do a register dump",
+	  "		[ raw on|off ]\n"
+	  "		[ file FILENAME ]\n" },
+	{ "-e", "--eeprom-dump", MODE_GEEPROM, "Do a EEPROM dump",
+	  "		[ raw on|off ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n" },
+	{ "-E", "--change-eeprom", MODE_SEEPROM,
+	  "Change bytes in device EEPROM",
+	  "		[ magic N ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n"
+	  "		[ value N ]\n" },
+	{ "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotiation" },
+	{ "-p", "--identify", MODE_PHYS_ID,
+	  "Show visible port identification (e.g. blinking)",
+	  "               [ TIME-IN-SECONDS ]\n" },
+	{ "-t", "--test", MODE_TEST, "Execute adapter self test",
+	  "               [ online | offline | external_lb ]\n" },
+	{ "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
+	{ "-n", "--show-nfc", MODE_GNFC,
+	  "Show Rx network flow classification options",
+	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
+	{ "-f", "--flash", MODE_FLASHDEV,
+	  "Flash firmware image from the specified file to a region on the device",
+	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
+	{ "-N", "--config-nfc", MODE_SNFC,
+	  "Configure Rx network flow classification options",
+	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+	{ "-x", "--show-rxfh-indir", MODE_GRXFHINDIR,
+	  "Show Rx flow hash indirection" },
+	{ "-X", "--set-rxfh-indir", MODE_SRXFHINDIR,
+	  "Set Rx flow hash indirection",
+	  "		equal N | weight W0 W1 ...\n" },
+	{ "-U", "--config-ntuple", MODE_SCLSRULE,
+	  "Configure Rx ntuple filters and actions",
+	  "		[ delete %d ] |\n"
+	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+	  "			[ proto %d [m %x] ]\n"
+	  "			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+	  "			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+	  "			[ tos %d [m %x] ]\n"
+	  "			[ l4proto %d [m %x] ]\n"
+	  "			[ src-port %d [m %x] ]\n"
+	  "			[ dst-port %d [m %x] ]\n"
+	  "			[ spi %d [m %x] ]\n"
+	  "			[ vlan-etype %x [m %x] ]\n"
+	  "			[ vlan %x [m %x] ]\n"
+	  "			[ user-def %x [m %x] ]\n"
+	  "			[ action %d ]\n"
+	  "			[ loc %d]]\n" },
+	{ "-u", "--show-ntuple", MODE_GCLSRULE,
+	  "Get Rx ntuple filters and actions",
+	  "		[ rule %d ]\n"},
+	{ "-P", "--show-permaddr", MODE_PERMADDR,
+	  "Show permanent hardware address" },
+	{ "-w", "--get-dump", MODE_GET_DUMP,
+	  "Get dump flag, data",
+	  "		[ data FILENAME ]\n" },
+	{ "-W", "--set-dump", MODE_SET_DUMP,
+	  "Set dump flag of the device",
+	  "		N\n"},
+	{ "-l", "--show-channels", MODE_GCHANNELS, "Query Channels" },
+	{ "-L", "--set-channels", MODE_SCHANNELS, "Set Channels",
+	  "               [ rx N ]\n"
+	  "               [ tx N ]\n"
+	  "               [ other N ]\n"
+	  "               [ combined N ]\n" },
+	{ "-h", "--help", MODE_HELP, "Show this help" },
+	{ NULL, "--version", MODE_VERSION, "Show version number" },
+	{}
 };
 

-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
