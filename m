From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Thu, 3 Aug 2006 11:18:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0608031101220.14955@bizon.gios.gov.pl>
References: <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net>
 <200607311015.40255.Christophe.Devriese@eurid.eu> <20060802.135859.91441473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-802685946-1154596693=:14955"
Cc: Christophe.Devriese@eurid.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:35509 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S932411AbWHCJTH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:19:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060802.135859.91441473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-802685946-1154596693=:14955
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 2 Aug 2006, David Miller wrote:
<CUT>
> Finally, I'm still a little stumped about why this change is necessary
> still, to be honest.

If I understand it correctly this patch fixes the "[PATCH] bonding:=20
suppress duplicate packets" patch:

http://www.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D8f903c708fcc2b579ebf16542bf6109bad593a1d;hp=3Debe19a4ed78d4a=
11a7e01cdeda25f91b7f2fcb5a

It seems that the original patch does not work properly in vlan=20
accelerated environment, which I reported 31 Mar 2006
  http://marc.theaimsgroup.com/?l=3Dbonding-devel&m=3D114381240718113&w=3D2

Anyway, I didn't test this patch yet but I'm going to di it ASAP.

Best regards,

 =09=09=09=09=09Krzysztof Ol=EAdzki
---187430788-802685946-1154596693=:14955--
