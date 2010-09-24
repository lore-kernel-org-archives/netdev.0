From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when able
 to sleep
Date: Sat, 25 Sep 2010 00:24:34 +0200
Message-ID: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
References: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
 <20100923212012.GA10925@electric-eye.fr.zoreil.com>
 <20100924131842.26f1fb1f@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 158.13.115-78.rev.gaoland.net ([78.115.13.158]:47953 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754650Ab0IXWYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 18:24:55 -0400
Content-Disposition: inline
In-Reply-To: <20100924131842.26f1fb1f@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> :
> Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> > Feel free to add a Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> > as soon as it will have been explicitely reported to improve the
> > situation (it is not clear in the PR above).
> 
> I'm pretty sure patch fix the problem, however yes, we do not have
> confirmation from reporter yet.

A success report would help me swallow a 6 parameters
rtl8169_alloc_rx_skb method.

The driver is not smart wrt partially allocated rx ring, especially
at init time. It considers a single init time skb allocation failure
fatal.

> Anyway atomic allocation should not be used in process context.

What do you mean ? tg3->open() does not seem to bother. It is not alone.

-- 
Ueimor
