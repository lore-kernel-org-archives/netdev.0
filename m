From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Thu, 4 Apr 2013 07:25:26 -0700
Message-ID: <20130404142526.GG9425@htj.dyndns.org>
References: <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop>
 <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
 <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
 <20130403212450.GD3411@htj.dyndns.org>
 <1365024575.13853.39.camel@edumazet-glaptop>
 <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com>
 <20130404140040.GB9425@htj.dyndns.org>
 <0000013dd56ce988-aff8039a-dcd8-4267-b1c8-b8db60b4e4cd-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:37400 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761715Ab3DDOZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:25:32 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so1460303pbb.10
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 07:25:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0000013dd56ce988-aff8039a-dcd8-4267-b1c8-b8db60b4e4cd-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 02:21:57PM +0000, Christoph Lameter wrote:
> On Thu, 4 Apr 2013, Tejun Heo wrote:
> 
> > Right, this is true, and we *do* wanna support this_cpu ops other than
> > this_cpu_ptr on per-cpu struct fields.  The usage is still somewhat
> > unusual tho.  Can we please add documentation in the comments too?
> 
> I posted a patch adding documentation yesterday and you took it.
> ???
> 
> Add comments where?

I was thinking above this_cpu_*() ops.  Let's make it as conspicious
as reasonably possible.  It's a similar problem with declaring per-cpu
arrays - there are a couple ways to do it and there's no way to
automatically reject the one which isn't preferred.  I don't know.
Maybe all we can do is periodic sweep through the source tree and fix
up the "wrong" ones.

Thanks.

-- 
tejun
