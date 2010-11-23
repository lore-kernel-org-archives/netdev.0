From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 20:38:58 +0200
Message-ID: <4CEC0A42.60209@iki.fi>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>	<20101123082404.5b8ad019@nehalam>	<4CEBEF7C.2060806@iki.fi> <20101123101302.54a9e4be@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51282 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab0KWSjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 13:39:03 -0500
Received: by eye27 with SMTP id 27so4858031eye.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 10:39:01 -0800 (PST)
In-Reply-To: <20101123101302.54a9e4be@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2010 08:13 PM, Stephen Hemminger wrote:
> On Tue, 23 Nov 2010 18:44:44 +0200
> Timo Ter=E4s <timo.teras@iki.fi> wrote:
>> On 11/23/2010 06:24 PM, Stephen Hemminger wrote:
>>> The GRE key is not really an IPv4 address. Why should the utilities
>>> use IPv4 address manipulation to format/scan it.  It makes more sen=
se
>>> to me to just use u32 an do the necessary ntohl.
>>
>> This is pretty much how iptunnel.c does it, so I copied the code. Wo=
uld
>> you prefer to format it as single u32 number? Or use something else =
for
>> formatting it similar to IPv4?
>>
>> In either case, we should change iptunnel.c to match ipxfrm.c. It'll=
 be
>> easier if both parts handling the gre key treat it equivalently.
>>
>> I think Cisco does indeed treat it as u32 number in the configuratio=
ns.
>> So I'm okay updating this patch, and fixing iptunnel.c side too. We
>> might still want to keep the parsing of ipv4 format to keep backward=
s
>> compatibility.
>=20
> My preference would be to take both dotted quad and a single
> number.

And I assume that when dumping stuff, it should be output as single
number. Or make that configurable with some switch?

I'll refresh my patch and fix iptunnel.c output tomorrow.
