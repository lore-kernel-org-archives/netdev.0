From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: kmemleak reports firmware loader funnies in iwlwifi
Date: Mon, 29 Jun 2009 17:35:31 +0300
Message-ID: <84144f020906290735p3f50e25bv5626b514ba7844fb@mail.gmail.com>
References: <20090626171933.GA23170@redhat.com>
	 <tnxy6rbv0oq.fsf@pc1117.cambridge.arm.com>
	 <84144f020906290248w474ad2ffpe6a8b5bede3d2c20@mail.gmail.com>
	 <1246286036.21450.35.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:35267 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbZF2Of3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 10:35:29 -0400
In-Reply-To: <1246286036.21450.35.camel@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Catalin,

On Mon, Jun 29, 2009 at 5:33 PM, Catalin Marinas<catalin.marinas@arm.com> wrote:
> I tried to do this but it has some other implications. If I add the vmap
> hook, I would need to add vunmap as well. On ARM, at least, iounmap
> calls vunmap (but not vmap) which means that I would need to add ioremap
> support as well. That's not a bug issue but this is more like a new
> feature than a bug fix.
>
> I propose that for now I disable the kmemleak warning for unknown
> pointers and add a patch to linux-next which tracks ioremap and vmap
> mappings. Does this sound fine?

Yup, makes sense.
