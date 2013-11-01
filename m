From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Bug 63871] New: BUG skbuff_head_cache (Tainted: G        W ): Object padding overwritten
Date: Sat, 2 Nov 2013 00:08:07 +0100
Message-ID: <20131101230807.GE30284@order.stressinduktion.org>
References: <bug-63871-27@https.bugzilla.kernel.org/> <20131101155620.b4388760cfb8562430e3039c@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	mikhail.v.gavrilov@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44419 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab3KAXII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 19:08:08 -0400
Content-Disposition: inline
In-Reply-To: <20131101155620.b4388760cfb8562430e3039c@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 01, 2013 at 03:56:20PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> Possible networking memory scribble?
> 
> On Sun, 27 Oct 2013 16:01:39 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > [12745.265370]  [<ffffffff815df9fe>] __alloc_skb+0x4e/0x2b0
> > [12745.265372]  [<ffffffff815d8de4>] sock_wmalloc+0x34/0x90
> > [12745.265375]  [<ffffffff8163a803>] __ip_append_data.isra.44+0x7c3/0x9c0
> > [12745.265377]  [<ffffffff816385a0>] ? ip_reply_glue_bits+0x60/0x60
> > [12745.265378]  [<ffffffff816384aa>] ? ip_setup_cork+0x7a/0x110
> > [12745.265380]  [<ffffffff8163c4f3>] ip_make_skb+0x113/0x160
> > [12745.265382]  [<ffffffff816385a0>] ? ip_reply_glue_bits+0x60/0x60
> > [12745.265384]  [<ffffffff8162e400>] ? __ip_route_output_key+0x360/0xb20
> > [12745.265386]  [<ffffffff81669faa>] udp_sendmsg+0x2ba/0xb70

Maybe this is the fix for this:

http://patchwork.ozlabs.org/patch/285292/

Greetings,

  Hannes
