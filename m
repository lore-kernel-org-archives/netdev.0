From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 20:51:00 +0100
Message-ID: <20100118195100.GB3157@del.dom.local>
References: <4B548DAE.3000205@trash.net>
 <1263833050-11635-1-git-send-email-hagen@jauu.net>
 <4B54B59D.5010108@gmail.com>
 <20100118193645.GH16482@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:60457 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab0ARTvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:51:06 -0500
Received: by fxm25 with SMTP id 25so842619fxm.21
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 11:51:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100118193645.GH16482@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 08:36:45PM +0100, Hagen Paul Pfeifer wrote:
> * Jarek Poplawski | 2010-01-18 20:25:17 [+0100]:
> 
> >I don't think this is needed; qdisc_dequeue_head() updated it already.
> 
> No, the bookkeeping stuff is done in the previous call layer. It is not really
> nice solved but to generalize this stuff adds unnecessary overhead.

Did you test it? IMHO "sch->q.qlen--" is done 2 times.

Jarek P.
