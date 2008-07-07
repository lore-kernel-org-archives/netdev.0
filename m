From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 7 Jul 2008 23:29:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807072307230.15459@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
 <4872854F.80603@candelatech.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-182763743-1215466152=:15459"
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:50022 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756749AbYGGV3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:29:21 -0400
In-Reply-To: <4872854F.80603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-182763743-1215466152=:15459
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 7 Jul 2008, Ben Greear wrote:

> Krzysztof Oledzki wrote:
>> Hello,
>>=20
>> I have a problem that I'm not able to connect from selected linux hosts =
to=20
>> a newly installed Netware 6.5 server. After two days of debugging I=20
>> discovered that the problem seems to be caused by an insufficient paddin=
g=20
>> of a .1q tagged packets.
>
> Last time this came up I looked up the RFC and according to it
> there is no need to pad beyond the normal 60 + 4, vlan tag or
> not.
>
> This is a bug in your intervening switch and/or Netware unless you actual=
ly=20
> see packets
> leaving Linux with less than 60 + 4 bytes.

Rather a Broadcom Corporation NetXtreme II driver "feature" as AFAIK=20
Netware 6.5 does not support .1Q natively and vlans are implemented=20
directly in network drivers, especially that everything worked with a=20
previous hardware (Intel 82541GI based).

So yes, it may not be a Linux bug but it would be nice to make Linux more=
=20
compatible with such configurations, of course if that is possible. Please=
=20
also note that this problem does not exists with Netware<->Netware=20
communication (both NetXtreme II<->NetXtreme II and 82541GI<->NetXtreme=20
II) so it seems that both Intel and Broadcom supports the "extened"=20
padding of .1Q packets in their Netware drivers.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-182763743-1215466152=:15459--
