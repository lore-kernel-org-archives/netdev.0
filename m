From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH 0/3] Add port-profile netlink support
Date: Mon, 03 May 2010 21:53:27 -0700
Message-ID: <20100504045327.9261.33330.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:39376 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab0EDEx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 00:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds port-profile netlink support and adds an
implementation to Cisco's enic netdev driver:

	1/3: Adds port-profile netlink RTM_SETLINK/RTM_GETLINK support, and
	     adds matching netdev ops net_{set|get}_vf_port_profile.

	2/3: Adds enic support for net_{set|get}_vf_port_profile for enic
	     dynamic devices.

	3/3: (please don't apply) Enables SR-IOV support for enic to
	     illustrate support for port-profile netlink using SR-IOV-
	     compliant devices.

The SETLINK/GETLINK support follows the model for other IFLA_VF_* msgs used
for SR-IOV devices where the receipent of the netlink msg is the PF, but the
target is the VF.

The intent of this patch set is to cover both definitions of port-profile
as defined by Cisco's enic use and as defined by VSI discover protocol (VDP),
used in VEPA implemenations.  While both definitions are based on pre-
standards, the concept of a port-profile to be applied to an external switch
port on behalf of a virtual machine interface is common, as well as many
of the fields defining the protocols.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
