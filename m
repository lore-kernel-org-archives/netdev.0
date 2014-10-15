From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC v4 net 1/3] ipv6: Remove BACKTRACK macro
Date: Tue, 14 Oct 2014 17:14:11 -0700
Message-ID: <20141015001409.GB27904@devbig242.prn2.facebook.com>
References: <1412966888-31384-1-git-send-email-kafai@fb.com>
 <1412966888-31384-2-git-send-email-kafai@fb.com>
 <20141014.150106.2250383188165649088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53154 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755536AbaJOAOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 20:14:17 -0400
Content-Disposition: inline
In-Reply-To: <20141014.150106.2250383188165649088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > +struct fib6_node *fib6_backtrack(struct fib6_node *fn,
> > +				 struct in6_addr *saddr);
> > +
> 
> I am completely mystified why you did this, could you explain the
> logic?  I want to know what drove you to make this exported.
>
> I marked it static in my example patch, and there is no caller outside
> of route.c
> 

I was thinking this function only works on 'struct fib6_node', so
it belongs to ip6_fib.c more than route.c.
f.e. like fib6_lookup() whose callers are also only in route.c

> Doing this also eliminates inlining opportunitites.
> 
> Please keep this private inside of route.c
I will keep it private in route.c and re-submit.

Do you have input on the function signature and also the following two
patches?

Thanks,
--Martin
