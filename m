From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [PATCH RFC 0/8] LLDP implementation for Linux
Date: Mon, 25 Jun 2012 22:21:50 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1206252206010.8021@debianer>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com> <4FE8B535.70900@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44623 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab2FYUV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 16:21:56 -0400
Received: by eeit10 with SMTP id t10so1392168eei.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 13:21:55 -0700 (PDT)
In-Reply-To: <4FE8B535.70900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 25 Jun 2012, John Fastabend wrote:
> On 6/25/2012 11:28 AM, Eldad Zack wrote:
> > Hi all,
> > 
> > This series of patches provides a partial LLDP (IEEE Std 802.1ab)
> > implementation.
> 
> Why do you want to implement this in the kernel? We've been doing this
> in user space for sometime without any issues and has some noted
> advantages. Reduces kernel bloat, easier to add extend, etc.

You have a point there. I don't have any real, I just wrote it for fun.

> What are we missing? Can we address any deficiencies here rather than
> embedded this into the kernel.

I will take a look, though it seems too feature complete :)

> No, netlink is much nicer for these types of things. User space
> can register for events and stay in sync and also all the other
> relevant events are using netlink UP/DOWN/DORMANT events for
> example.

I had a hunch that it might be the case. Thanks!

> > 
> > Thanks in advance if you're taking the time to review it or test it!
> > 
> 
> I'll scan the patches shortly.

Thanks for that (if you'd still like to) and all your comments, much 
appreciated!

Eldad
