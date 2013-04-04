From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Thu, 4 Apr 2013 07:00:40 -0700
Message-ID: <20130404140040.GB9425@htj.dyndns.org>
References: <1364475933.15753.36.camel@edumazet-glaptop>
 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop>
 <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
 <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
 <20130403212450.GD3411@htj.dyndns.org>
 <1365024575.13853.39.camel@edumazet-glaptop>
 <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35230 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760177Ab3DDOAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:00:47 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so1425325pde.23
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 07:00:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Christoph.

On Thu, Apr 04, 2013 at 01:52:00PM +0000, Christoph Lameter wrote:
> The method that I proposed is also conforming with the use of other
> this_cpu_ops. F.e. In order to do a read one would need to do
> 
> x = this_cpu_read(percpu_pointer->field)
> 
> 
> 
> 
> x = this_cpu_read(percpu_pointer)->field
> 
> does not work (and does not pass sparse).

Right, this is true, and we *do* wanna support this_cpu ops other than
this_cpu_ptr on per-cpu struct fields.  The usage is still somewhat
unusual tho.  Can we please add documentation in the comments too?

Thanks.

-- 
tejun
