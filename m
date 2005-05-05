From: Mike Christie <michaelc@cs.wisc.edu>
Subject: [PATCH 0/3] add open iscsi netlink interface to iscsi transport class
Date: Wed, 04 May 2005 19:53:09 -0700
Message-ID: <42798A95.6070909@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-scsi-owner@vger.kernel.org>
To: linux-scsi <linux-scsi@vger.kernel.org>,
	netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches add the linux-iscsi-5.X/open-iscsi project's 
netlink interface to the iscsi transport class since the groups doing 
iSCSI over TCP (this module is completed now and will be submitted in a 
seperate mail), iSCSI over SCTP and iSER are using it for a common 
interface and to share code.

The answers to why netlink and why push so much to userspace can be 
found here http://open-iscsi.org/.

Patches

1. add-iscsi-netlink-def.patch - include/linux/netlink.h changes (added 
new protocol NETLINK_ISCSI)

2.  common-iscsi-headers.patch - Common header files:
  - iscsi_if.h (user/kernel #defines);
  - iscsi_proto.h (RFC3720 #defines and types);
  - iscsi_ifev.h (user/kernel events).

3. integrate-iscsi-netlink.patch - incorporate the 
open-iscsi/linux-iscsi netlink interface into the iscsi transport class.


Thanks,

Linux-iscsi Team
