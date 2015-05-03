From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: PATCH: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Sun, 03 May 2015 23:39:30 +0200
Message-ID: <55469592.6080305@iogearbox.net>
References: <5546065B.6080706@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39800 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbbECVjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 17:39:32 -0400
In-Reply-To: <5546065B.6080706@fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mathias,

On 05/03/2015 01:28 PM, Mathias Kretschmer wrote:
> Hi,
>
> following up on my initial post and the feedback I have received,
> please find attached/in-line an updated patch.

Yep, thanks for following up on this.

However, your submission (https://patchwork.ozlabs.org/patch/467377/)
format is not correct. Your email client corrupted the whitespace,
your Signed-off-by is missing, a proper commit description is missing
and which tree your patch is targeted at. I presume -net tree as it's
a fix.

You're best off sending this patch via git-send-email(1), see also
Documentation/SubmittingPatches from the kernel tree.

Taking a random example submission from patchwork, this is how the end
result could look like:

   https://patchwork.ozlabs.org/patch/466743/

Thus, if you just write a proper commit message in git and use
git-format-patch(1) and git-send-email(1), you should be all set. Hope
that helps.

Cheers,
Daniel

> Changes:
> *) keep the unlikely() in the case sock_alloc_send_skb() fails, as here we enter the slow path, anyway.
> *) pass on the return code from sock_alloc_send_skb(), i.e. EGAIN
>
> Please consider this for inclusion.
>
> Cheers,
>
> Mathias
