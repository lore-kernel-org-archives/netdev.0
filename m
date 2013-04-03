From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Wed, 03 Apr 2013 14:29:35 -0700
Message-ID: <1365024575.13853.39.camel@edumazet-glaptop>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
	 <1364475933.15753.36.camel@edumazet-glaptop>
	 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
	 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
	 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
	 <1364833887.5113.161.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
	 <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
	 <20130403212450.GD3411@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:65387 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760497Ab3DCV3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 17:29:38 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so834344dad.18
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 14:29:37 -0700 (PDT)
In-Reply-To: <20130403212450.GD3411@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 14:24 -0700, Tejun Heo wrote:

> I don't know about this one.  I actually prefer the latter in that the
> pointer being passed into this_cpu_ptr() is something which is the
> actual percpu pointer either from variable declaration or the
> allocator.  Sure, they both are just different expressions of the same
> thing but the former requires an extra guarantee from percpu subsystem
> that the accessors would work for pointers which aren't the exact
> values defined or allocated.  I'd much prefer unfiying things toward
> the latter than the former.

I agree with you, I prefer &this_cpu_ptr(percpu_pointer)->field

The offset is added after getting the address of the (percpu) base
object.
