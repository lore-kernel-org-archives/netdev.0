From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPV6 routing problem
Date: Wed, 22 Jan 2014 08:11:01 +0100
Message-ID: <20140122071101.GC28225@order.stressinduktion.org>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com> <20140122070759.GB28225@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Sharat Masetty <sharat04@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57136 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaAVHLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:11:02 -0500
Content-Disposition: inline
In-Reply-To: <20140122070759.GB28225@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 08:07:59AM +0100, Hannes Frederic Sowa wrote:
> Hi!
> 
> On Tue, Jan 21, 2014 at 06:41:58PM -0700, Sharat Masetty wrote:
> >  I have an IPV6 routing problem that has only surfaced on a 3.10
> > kernel version. This problem is not seen on 3.4 kernel. I will keep
> > the problem statement as brief as possible.
> 
> Could you do me a favor and test this on a recent 3.13 kernel? Thanks!
> Please also state the specific kernel version (I guess you use one).

+stable.

A quick test worked for me. Maybe you could try with CONFIG_IPV6_ROUTER_PREF
enabled and one time with it disabled.

We should make this knob a runtime setting soon...

Thanks,

  Hannes
