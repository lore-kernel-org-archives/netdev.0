From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Tue, 10 Jun 2008 19:07:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806101906120.12641@bizon.gios.gov.pl>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net>
 <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl>
 <484E4343.5090606@trash.net> <Pine.LNX.4.64.0806101545460.12641@bizon.gios.gov.pl>
 <484E88FD.3000908@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-442060285-1213117621=:12641"
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:47584 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbYFJRHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 13:07:50 -0400
In-Reply-To: <484E88FD.3000908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-442060285-1213117621=:12641
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 10 Jun 2008, Patrick McHardy wrote:
<CUT>

>> As you can see we still check if nat->ct is NULL here. So, or the check =
is=20
>> now unnecessary, or it is still possible that nat->ct may become NULL. I=
f=20
>> the second statement is true than we may need to check ct before calling=
=20
>> same_src in the find_appropriate_src function.
>
> No, the nf_nat_cleanup_nat function can be called for a NAT extension
> that isn't in the hash yet (and thus has nat->ct =3D=3D NULL) when the
> nf_conntrack_alter_reply() call in nf_nat_setup_info() allocates a
> helper extension and need to realloc the NAT extension space.

OK, thank you for the explanation.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-442060285-1213117621=:12641--
