From: "Julius Volz" <juliusv@google.com>
Subject: Re: Adding IPv6 support to IPVS: some general questions about kernel development
Date: Tue, 1 Apr 2008 13:25:43 +0200
Message-ID: <f4845fc0804010425t1e92cd25m45454a2940a5038e@mail.gmail.com>
References: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com>
	 <47F123C5.70804@trash.net>
	 <f4845fc0803311129w4bdb0415p56c3f11c935c3020@mail.gmail.com>
	 <20080401052003.GC21127@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:30579 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463AbYDAL0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 07:26:09 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m31BPjlf031493
	for <netdev@vger.kernel.org>; Tue, 1 Apr 2008 12:25:45 +0100
Received: from wr-out-0506.google.com (wra76.prod.google.com [10.54.1.76])
	by zps38.corp.google.com with ESMTP id m31BPi1A008012
	for <netdev@vger.kernel.org>; Tue, 1 Apr 2008 04:25:44 -0700
Received: by wr-out-0506.google.com with SMTP id 76so1241961wra.10
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 04:25:44 -0700 (PDT)
In-Reply-To: <20080401052003.GC21127@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 1, 2008, Simon Horman wrote:
> On Mon, Mar 31, 2008 at 08:29:30PM +0200, Julius Volz wrote:
>  > On Mon, Mar 31, 2008, Patrick McHardy <kaber@trash.net> wrote:
>  > >  net/ipvs or net/netfilter/ipvs sound fine. The second is probably
>  > >  better since at some point we should try to merge the duplicated
>  > >  conntrack functionality if possible.
>  >
>  > Sure, since IPVS is basically a netfilter extension, that sounds good
>  > to me. Could all the IPv4- and IPv6-specific functionality (as opposed
>  > to the commonly used code) also end up in there or would that still
>  > have to reside under ipv[4,6]/...?
>  >
>  > Does it seem wise to do this move as the first thing in this process?
>  > That would probably be a good starter exercise to get to know the
>  > whole process!
>
>  I think that sounds like an excellent idea. net/netfilter/ipvs sounds
>  fine to me, though think that IPVS is fairly loosely tied to nefilter,
>  so if it was only up to me I would go for net/ipvs.

Ok, I will do this soon then! I will go for net/netfilter/ipvs (I
don't really care though) unless anyone complains.

Julius

-- 
Google Switzerland GmbH
