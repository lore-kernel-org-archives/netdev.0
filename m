From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH v1] ethtool: properly indent man sub-options
Date: Thu,  7 Jan 2016 17:50:43 -0800
Message-ID: <1452217843-18254-1-git-send-email-jesse.brandeburg@intel.com>
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7587 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbcAHBxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 20:53:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool.8 file was full of lots of incorrectly indented
bits.  This fixes the arguments to options to be indented in
a visually appealing way.

Before:
       -K --features --offload
              Changes the offload parameters and other features of the
              specified network device.  The following feature names
              are built-in and others may be defined by the kernel.

       rx on|off
              Specifies whether RX checksumming should be enabled.

       tx on|off
              Specifies whether TX checksumming should be enabled.

After:
       -K --features --offload
              Changes  the  offload parameters and other features of the
              specified network device.  The following feature names are
              built-in and others may be defined by the kernel.

           rx on|off
                  Specifies whether RX checksumming should be enabled.

           tx on|off
                  Specifies whether TX checksumming should be enabled.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 ethtool.8.in | 41 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 37 insertions(+), 4 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index eeffa70..38739c7 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -365,6 +365,7 @@ Queries the specified Ethernet device for pause parameter information.
 .TP
 .B \-A \-\-pause
 Changes the pause parameters of the specified Ethernet device.
+.RS 4
 .TP
 .A2 autoneg on off
 Specifies whether pause autonegotiation should be enabled.
@@ -374,6 +375,7 @@ Specifies whether RX pause should be enabled.
 .TP
 .A2 tx on off
 Specifies whether TX pause should be enabled.
+.RE
 .TP
 .B \-c \-\-show\-coalesce
 Queries the specified network device for coalescing information.
@@ -386,6 +388,7 @@ Queries the specified network device for rx/tx ring parameter information.
 .TP
 .B \-G \-\-set\-ring
 Changes the rx/tx ring parameters of the specified network device.
+.RS 4
 .TP
 .BI rx \ N
 Changes the number of ring entries for the Rx ring.
@@ -398,6 +401,7 @@ Changes the number of ring entries for the Rx Jumbo ring.
 .TP
 .BI tx \ N
 Changes the number of ring entries for the Tx ring.
+.RE
 .TP
 .B \-i \-\-driver
 Queries the specified network device for associated driver information.
@@ -419,6 +423,14 @@ Retrieves and prints an EEPROM dump for the specified network device.
 When raw is enabled, then it dumps the raw EEPROM data to stdout. The
 length and offset parameters allow dumping certain portions of the EEPROM.
 Default is to dump the entire EEPROM.
+.RS 4
+.TP
+.BI raw \ on|off
+.TP
+.BI offset \ N
+.TP
+.BI length \ N
+.RE
 .TP
 .B \-E \-\-change\-eeprom
 If value is specified, changes EEPROM byte for the specified network device.
@@ -436,6 +448,7 @@ offload and other features.
 Changes the offload parameters and other features of the specified
 network device.  The following feature names are built-in and others
 may be defined by the kernel.
+.RS 4
 .TP
 .A2 rx on off
 Specifies whether RX checksumming should be enabled.
@@ -472,14 +485,17 @@ Specifies whether Rx ntuple filters and actions should be enabled
 .TP
 .A2 rxhash on off
 Specifies whether receive hashing offload should be enabled
+.RE
 .TP
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
 blinking one or more LEDs on the specific network port.
+.RS 4
 .TP
-.B N
+.BN
 Length of time to perform phys-id, in seconds.
+.RE
 .TP
 .B \-P \-\-show\-permaddr
 Queries the specified network device for permanent hardware address.
@@ -494,6 +510,7 @@ statistics.
 .TP
 .B \-t \-\-test
 Executes adapter selftest on the specified network device. Possible test modes are:
+.RS 4
 .TP
 .B offline
 Perform full set of tests, possibly interrupting normal operation
@@ -505,12 +522,14 @@ Perform limited set of tests, not interrupting normal operation,
 .B external_lb
 Perform full set of tests, as for \fBoffline\fR, and additionally an
 external-loopback test.
+.RE
 .TP
 .B \-s \-\-change
 Allows changing some or all settings of the specified network device.
 All following options only apply if
 .B \-s
 was specified.
+.RS 4
 .TP
 .BI speed \ N
 Set speed in Mb/s.
@@ -620,11 +639,13 @@ wol	0x4000  Wake-on-LAN status
 .TE
 .PP
 The precise meanings of these type flags differ between drivers.
+.RE
 .PD
 .RE
 .TP
 .B \-n \-u \-\-show\-nfc \-\-show\-ntuple
 Retrieves receive network flow classification options or rules.
+.RS 4
 .TP
 .BR rx\-flow\-hash \ \*(FL
 Retrieves the hash options for the specified flow type.
@@ -645,11 +666,13 @@ sctp6	SCTP over IPv6
 .TP
 .BI rule \ N
 Retrieves the RX classification rule with the given ID.
+.RE
 .PD
 .RE
 .TP
 .B \-N \-U \-\-config\-nfc \-\-config\-ntuple
 Configures receive network flow classification options or rules.
+.RS 4
 .TP
 .BR rx\-flow\-hash \ \*(FL \: \*(HO
 Configures the hash options for the specified flow type.
@@ -688,7 +711,6 @@ mask may be specified immediately after the value using the \fBm\fR
 keyword, or separately using the field name keyword with \fB-mask\fR
 appended, e.g. \fBsrc-mask\fR.
 .PD
-.RE
 .TP
 .BR src \ \*(MA\ [ m \ \*(MA]
 Includes the source MAC address, specified as 6 bytes in hexadecimal
@@ -769,6 +791,7 @@ of the rule ordering process.
 .TP
 .BI delete \ N
 Deletes the RX classification rule with the given ID.
+.RE
 .TP
 .B \-w \-\-get\-dump
 Retrieves and prints firmware dump for the specified network device.
@@ -790,6 +813,7 @@ Retrieves the receive flow hash indirection table and/or RSS hash key.
 .TP
 .B \-X \-\-set\-rxfh\-indir \-\-rxfh
 Configures the receive flow hash indirection table and/or RSS hash key.
+.RS 4
 .TP
 .BI hkey
 Sets RSS hash key of the specified network device. RSS hash key should be of device supported length.
@@ -804,10 +828,12 @@ between the first \fIN\fR receive queues.
 Sets the receive flow hash indirection table to spread flows between
 receive queues according to the given weights.  The sum of the weights
 must be non-zero and must not exceed the size of the indirection table.
+.RE
 .TP
 .B \-f \-\-flash
 Write a firmware image to flash or other non-volatile memory on the
 device.
+.RS 4
 .TP
 .I file
 Specifies the filename of the firmware image.  The firmware must first
@@ -819,8 +845,8 @@ If the device stores multiple firmware images in separate regions of
 non-volatile memory, this parameter may be used to specify which
 region is to be written.  The default is 0, requesting that all
 regions are written.  All other values are driver-dependent.
-.PD
 .RE
+.PD
 .TP
 .B \-l \-\-show\-channels
 Queries the specified network device for the numbers of channels it has.
@@ -828,6 +854,7 @@ A channel is an IRQ and the set of queues that can trigger that IRQ.
 .TP
 .B \-L \-\-set\-channels
 Changes the numbers of channels of the specified network device.
+.RS 4
 .TP
 .BI rx \ N
 Changes the number of channels with only receive queues.
@@ -840,6 +867,7 @@ Changes the number of channels used only for other purposes e.g. link interrupts
 .TP
 .BI combined \ N
 Changes the number of multi-purpose channels.
+.RE
 .TP
 .B \-m \-\-dump\-module\-eeprom \-\-module\-info
 Retrieves and if possible decodes the EEPROM from plugin modules, e.g SFP+, QSFP.
@@ -853,10 +881,12 @@ network device driver.
 .TP
 .B \-\-set\-priv\-flags
 Sets the device's private flags as specified.
+.RS 4
 .PP
 .I flag
 .A1 on off
 Sets the state of the named private flag.
+.RE
 .TP
 .B \-\-show\-eee
 Queries the specified network device for its support of Energy-Efficient
@@ -864,6 +894,7 @@ Ethernet (according to the IEEE 802.3az specifications)
 .TP
 .B \-\-set\-eee
 Sets the device EEE behaviour.
+.RS 4
 .TP
 .A2 eee on off
 Enables/disables the device support of EEE.
@@ -879,6 +910,7 @@ Values are as for
 .BI tx-timer \ N
 Sets the amount of time the device should stay in idle mode prior to asserting
 its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
+.RE
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
@@ -894,7 +926,8 @@ Eli Kupermann,
 Scott Feldman,
 Andi Kleen,
 Alexander Duyck,
-Sucheta Chakraborty.
+Sucheta Chakraborty,
+Jesse Brandeburg.
 .SH AVAILABILITY
 .B ethtool
 is available from
-- 
1.8.3.1
