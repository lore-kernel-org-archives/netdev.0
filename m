From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Mon, 6 Oct 2008 22:14:30 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0810062208370.6758@bizon.gios.gov.pl>
References: <20081006173024.2741cc01@speedy>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-278195101-1223324070=:6758"
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:54717 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbYJFUbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 16:31:45 -0400
In-Reply-To: <20081006173024.2741cc01@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-278195101-1223324070=:6758
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT



On Mon, 6 Oct 2008, Stephen Hemminger wrote:

> Propogate MTU changes of underlying device to all related VLAN
> devices.
> see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742

Not sure about this... Some switches (HP ProCurve for example) allow to 
select which vlan accepts jumbo frames and which does not and attach both 
to the same port. It is quite useful as you are able to setup one vlan 
with jumbo frames dedicated for example to servers connected by 1G/10G 
links, and a second vlan with standard 1500 MTU distributed to non 
jumbo-aware switches/workstations.

Best regards,

 				Krzysztof Olêdzki
---1144830174-278195101-1223324070=:6758--
