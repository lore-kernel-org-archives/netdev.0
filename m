From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Problem with sky2 (Yukon-EC)
Date: Mon, 30 Jun 2008 21:56:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806302154000.4958@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1293697896-1214855817=:4958"
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:43262 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383AbYF3T5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:57:01 -0400
In-Reply-To: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1293697896-1214855817=:4958
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 30 Jun 2008, Krzysztof Oledzki wrote:

> Hello,
>
> I have several servers with sky2 NIC (bonding + vlan):

<CUT>
> It seems that there is somethig wrong with the receiver hang workaround c=
ode.=20
> After such reset the card is not longer able to receive traffic. Maybe it=
 is=20
> somehow related to vlans?
>
> This problem exists in 2.6.21/2.6.22/2.6.24. I have not yet tested=20
> 2.6.25/2.6.26, any chances it get fixed there?

Are there any chances this patch may fix my problem:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=3Dd494eacde8858f9b53f5c640692caf14eb3c8239
?

If so it seems to be a good -stable candidate.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1293697896-1214855817=:4958--
