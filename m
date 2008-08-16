From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 21:15:16 +0300
Message-ID: <200808162115.16346.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808161828.49068.denys@visp.net.lb> <20080816155943.GD7519@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51116 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbYHPSQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 14:16:24 -0400
In-Reply-To: <20080816155943.GD7519@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, i did apply fix for another problem.

Other patches applied:
[PATCH] pkt_sched: Fix unlocking in tc_ctl_tfilter()
[PATCH] pkt_sched: Add lockdep annotation for qdisc locks

On Saturday 16 August 2008, Jarek Poplawski wrote:
> On Sat, Aug 16, 2008 at 06:28:48PM +0300, Denys Fedoryshchenko wrote:
> > Triggered panic by "batch" shaper "reapply".
> >
> > Aug 16 18:26:29 192.168.20.66 [ 2920.823068] BUG: unable to handle kernel
> > Aug 16 18:26:29 192.168.20.66 NULL pointer dereference
> > Aug 16 18:26:29 192.168.20.66 at 00000000
> > Aug 16 18:26:29 192.168.20.66 [ 2920.823068] IP:
> > Aug 16 18:26:29 192.168.20.66 [<c013c083>] find_usage_forwards+0x7e/0x92
>
> ...
>
> This seems to be a different bug. Did you run this earlier (before the
> last two patches)? I'd prefer to fix this oops from the beginning of
> this thread first, so it would be better to test these patches without
> changing conditions.
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


