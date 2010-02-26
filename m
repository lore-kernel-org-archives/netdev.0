From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool PATCH 2/2] ethtool: Update manpage with n-tuple information
Date: Fri, 26 Feb 2010 03:56:03 -0800
Message-ID: <20100226115603.20259.93232.stgit@localhost.localdomain>
References: <20100226115544.20259.36760.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:55536
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935516Ab0BZL4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 06:56:22 -0500
In-Reply-To: <20100226115544.20259.36760.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Add n-tuple information to the ethtool manpage.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool.8 |  102 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index b45d171..eb6430b 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -214,6 +214,40 @@ ethtool \- Display or change ethernet card settings
 .I ethX
 .RI FILE
 .RI [ N ]
+
+.B ethtool \-u|\-\-show\-ntuple
+.I ethX
+
+.B ethtool \-U|\-\-config\-ntuple
+.I ethX
+.RB [ flow-type
+.RB tcp4|udp4|sctp4 ]
+.RB [ src-ip
+.IR addr ]
+.RB [ src-ip-mask
+.IR mask ]
+.RB [ dst-ip
+.IR addr ]
+.RB [ dst-ip-mask
+.IR mask ]
+.RB [ src-port
+.IR port ]
+.RB [ src-port-mask
+.IR mask ]
+.RB [ dst-port
+.IR port ]
+.RB [ dst-port-mask
+.IR mask ]
+.RB [ vlan
+.IR VLAN-tag ]
+.RB [ vlan-mask
+.IR mask ]
+.RB [ user-def
+.IR data ]
+.RB [ user-def-mask
+.IR mask ]
+.RB [ action
+.IR queue\ or\ drop ]
 .SH DESCRIPTION
 .BI ethtool
 is used for querying settings of an ethernet device and changing them.
@@ -517,6 +551,74 @@ A number to identify flash region where the image should be flashed.
 Default region is 0 which denotes all regions in the flash.
 .PD
 .RE
+.TP
+.B \-u \-\-show-ntuple
+Get Rx ntuple filters and actions, then display them to the user.
+.PD
+.RE
+.TP
+.B \-U \-\-config-ntuple
+Configure Rx ntuple filters and actions
+.TP
+.B flow-type tcp4|udp4|sctp4
+.RS
+.PD 0
+.TP 3
+.BR "tcp4" "    TCP over IPv4"
+.TP 3
+.BR "udp4" "    UDP over IPv4"
+.TP 3
+.BR "sctp4" "   SCTP over IPv4"
+.PD
+.RE
+.TP
+.BI src-ip \ addr
+Includes the source IP address, specified in hex.
+.TP
+.BI src-ip-mask \ mask
+Specify a mask for the source IP address, specified in hex.
+.TP
+.BI dst-ip \ addr
+Includes the destination IP address, specified in hex.
+.TP
+.BI dst-ip-mask \ mask
+Specify a mask for the destination IP address, specified in hex.
+.TP
+.BI src-port \ port
+Includes the source port, specified in decimal.
+.TP
+.BI src-port-mask \ mask
+Specify a mask for the source port, specified in hex.
+.TP
+.BI dst-port \ port
+Includes the destination port, specified in decimal.
+.TP
+.BI dst-port-mask \ mask
+Specify a mask for the destination port, specified in hex.
+.TP
+.BI vlan \ VLAN-tag
+Includes the VLAN tag, specified in hex.
+.TP
+.BI vlan-mask \ mask
+Specify a mask for the VLAN tag, specified in hex.
+.TP
+.BI user-def \ data
+Includes 64-bits of user-specific data, specified in hex.
+.TP
+.BI user-def-mask \ mask
+Specify a mask for the user-specific data, specified in hex.
+.TP
+.BI action \ N
+Specifies either the Rx queue to send packets to, or to drop
+the matched flow.
+.RS
+.PD 0
+.TP 3
+.BR "-1" "             Drop the matched flow"
+.TP 3
+.BR "0 or higher" "    Rx queue to route the flow"
+.PD
+.RE
 .SH BUGS
 Not supported (in part or whole) on all ethernet drivers.
 .SH AUTHOR

