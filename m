From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Thu, 10 Aug 2006 20:18:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0608102013020.9012@bizon.gios.gov.pl>
References: <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net>
 <200607311015.40255.Christophe.Devriese@eurid.eu> <20060802.135859.91441473.davem@davemloft.net>
 <Pine.LNX.4.64.0608031101220.14955@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-2048743363-1155233903=:9012"
Cc: Christophe.Devriese@eurid.eu, Jay Vosburgh <fubar@us.ibm.com>,
	Kenzo Iwami <k-iwami@cj.jp.nec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:29108 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1751446AbWHJS00
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 14:26:26 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0608031101220.14955@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-2048743363-1155233903=:9012
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 3 Aug 2006, Krzysztof Oledzki wrote:

>
>
> On Wed, 2 Aug 2006, David Miller wrote:
> <CUT>
>> Finally, I'm still a little stumped about why this change is necessary
>> still, to be honest.
>
> If I understand it correctly this patch fixes the "[PATCH] bonding: suppr=
ess=20
> duplicate packets" patch:
>
> http://www.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommitdiff;h=3D8f903c708fcc2b579ebf16542bf6109bad593a1d;hp=3Debe19a4ed78=
d4a11a7e01cdeda25f91b7f2fcb5a
>
> It seems that the original patch does not work properly in vlan accelerat=
ed=20
> environment, which I reported 31 Mar 2006
> http://marc.theaimsgroup.com/?l=3Dbonding-devel&m=3D114381240718113&w=3D2
>
> Anyway, I didn't test this patch yet but I'm going to di it ASAP.

OK, this patch really solves the bug from my report. Are there any chances=
=20
for similar fix in the net-2.6.19.git?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-2048743363-1155233903=:9012--
