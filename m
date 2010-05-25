From: Shirley Ma <mashirle@us.ibm.com>
Subject: RE: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Tue, 25 May 2010 09:51:29 -0700
Message-ID: <1274806289.18023.57.camel@localhost.localdomain>
References: <1274473846.8701.25.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
	 <1274720919.18023.19.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C0E05@orsmsx508.amr.corp.intel.com>
	 <1274780239.18023.48.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A7A58B5F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:49023 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631Ab0EYQv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 12:51:59 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755A7A58B5F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 08:57 -0700, Rose, Gregory V wrote:
> Just use ifconfig and vconfig utilities to set the MAC and VLAN for
> each VF.  There shouldn't be any need for secondary addresses because
> they're not like physical devices where each VF has a pre-programmed
> HW MAC address.  The initial MAC address of each VF is generated on
> the fly during the PF driver initialization. You can change it as you
> see fit and then put the VF on a VLAN using vconfig.  After you do
> that you have a macvlan filter for that VF.

I run macvlan test not vlan. macvlan is used to give a second MAC
address to a network adapter and see it as a new device at the higher
levels. The command is used as follow:

ip link add link eth4 address 54:52:00:35:e3:20 macvlan2 type macvlan

It will create an interface name macvlan2 with above MAC address. In
kernel, netdev eth4 maintains this secondary address.

Thanks
Shirley


