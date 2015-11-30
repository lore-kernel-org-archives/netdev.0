From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Increasing skb->mark size
Date: Mon, 30 Nov 2015 11:10:38 +0900
Message-ID: <CAKD1Yr2vWpKsibNY6ShYZiKLMFSD_2gxRVa=DyXx5jkEs25AZw@mail.gmail.com>
References: <1448397144.14854.27.camel@mattb-dl> <20151124203602.GB23215@breakpoint.cc>
 <1448398614.14854.39.camel@mattb-dl> <20151130020816.GB29878@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36032 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbbK3CK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 21:10:58 -0500
Received: by ykdr82 with SMTP id r82so167981853ykd.3
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 18:10:57 -0800 (PST)
In-Reply-To: <20151130020816.GB29878@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 11:08 AM, Florian Westphal <fw@strlen.de> wrote:
>
> > While connlabels provide 128bits of space skb->mark is still only 32
> > bits. Since we are using connection tracking to simply restore skb->mark
> > the use of connlabels by itself doesn't solve the problem I outlined
> > above. skb->mark would still needs to be increased in size.
>
> We have ctnetlink which allows direct setting of ctmark/ctlabels.

Can those labels be set early enough in the stack to affect the source
address chosen for outgoing connections?
