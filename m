From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Fri, 10 Jun 2016 07:28:38 -0700
Message-ID: <1465568918.7945.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465561289-15401-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a@unstable.cc, sw@simonwunderlich.de,
	mareklindner@neomailbox.ch, sven@narfation.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34294 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbcFJO2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 10:28:43 -0400
Received: by mail-pa0-f68.google.com with SMTP id ug1so5191385pab.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 07:28:43 -0700 (PDT)
In-Reply-To: <1465561289-15401-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-10 at 14:21 +0200, Florian Westphal wrote:
> ... its not returned anywhere.
> 
> BATMAN uses it as an intermediate return value to signal
> forwarding vs. buffering, but it will not return POLICED to
> callers outside of BATMAN.
> 
> sch_atm uses it, but on closer look its not returned either since
> the initialisation is always overwritten with qdisc_enqueue() retval.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>

I have a patch series removing couples of qdisc_unthrottled() and
qdisc_throttled() which are pretty expensive for very little gain.
