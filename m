From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works =?iso-8859-1?q?fine!=092=2E6=2E28?=
Date: Mon, 12 Jan 2009 22:01:19 +0200
Message-ID: <200901122201.19616.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901122038.05199.denys@visp.net.lb> <Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42676 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbZALUBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 15:01:33 -0500
In-Reply-To: <Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are enabled

Router-Dora /config # zcat /proc/config.gz |grep HIGH_RES
CONFIG_HIGH_RES_TIMERS=y
Router-Dora /config # zcat /proc/config.gz |grep HZ
CONFIG_NO_HZ=y


On Monday 12 January 2009 21:58:22 Jesper Dangaard Brouer wrote:
> On Mon, 12 Jan 2009, Denys Fedoryschenko wrote:
> > End of my story:
> > 1000HZ solved issue. HTB and HFSC keeps rate MUCH better.
> > Both looks like perform similar, but because it is real load scenario, i
> > cannot measure which one is better.
>
> If that was you problem, you should consider enabling
> CONFIG_HIGH_RES_TIMERS (and possibly CONFIG_NO_HZ).
>
> Patrick McHardy has at some point made the sched code independent of the
> HZ value, but only when the HIGH_RES_TIMERS are enabled.
>
> Cheers,
>    Jesper Brouer
>
> --
> -------------------------------------------------------------------
> MSc. Master of Computer Science
> Dept. of Computer Science, University of Copenhagen
> Author of http://www.adsl-optimizer.dk
> -------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


