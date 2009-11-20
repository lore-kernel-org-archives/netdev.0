From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 12:51:26 -0800
Message-ID: <43e72e890911201251t6210ee19n177eaf003a4fffc@mail.gmail.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:56648 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbZKTUvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:51:40 -0500
In-Reply-To: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 12:45 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> Everyone and their mother reinvents the wheel when it comes to
> backporting kernel modules. It a painful job and it seems to me an
> alternative is possible. If we can write generic compatibilty code for
> a new routine introduced on the next kernel how about just merging it
> to the kernel under some generic compat module. This would be
> completey ignored by everyone using the stable kernel but can be
> copied by anyone doing backport work.
>
> So I'm thinking something as simple as a generic compat/comat.ko with
> compat-2.6.32.[ch] files.

FWIW, I meant a compat-2.6.32.[ch] and compat-2.6.31.[ch] and so on.
All these would link to the compat.ko

  Luis
