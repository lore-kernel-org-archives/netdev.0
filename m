From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: What now when we're [almost] out of ADVERTISED bits?
Date: Sun, 29 Nov 2015 23:39:38 +0200
Message-ID: <CAJ3xEMj4ygmuSnxS-wkwukYyMgaA2omSQ+0MvY1MZKVv4_U6=A@mail.gmail.com>
References: <CO2PR11MB00887F0A656EFB801BA2599797010@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	David Decotigny <ddecotig@gmail.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32816 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbbK2Vjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 16:39:39 -0500
Received: by iouu10 with SMTP id u10so157707381iou.0
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 13:39:39 -0800 (PST)
In-Reply-To: <CO2PR11MB00887F0A656EFB801BA2599797010@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2015 at 3:53 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
> [I suspect there was probably some discussion over this,
> but I couldn't find it; References would be welcome]

there was a work by David Decotigny that should have solved the out of
bits problem here [1]. Maybe it should be revived.

[1] https://lkml.org/lkml/2015/1/26/882


> So it appears we're almost out of bits for new advertised speeds;
> I'm currently looking at adding 100g.
>
> Assuming we want [and we do want] to have those in the `supported',
> `advertising' and `lp_advertising' fields, the 2 reserve fields in
> ethtool_cmd would not be sufficient [unless we break them into 4 u16].
> Or are we planning something more generic than this for future bits?

Or.
