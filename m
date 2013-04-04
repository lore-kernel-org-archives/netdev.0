From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Thu, 04 Apr 2013 07:29:46 -0700
Message-ID: <1365085786.13853.65.camel@edumazet-glaptop>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
	 <1364475933.15753.36.camel@edumazet-glaptop>
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
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <htejun@gmail.com>, RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43201 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761009Ab3DDO3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:29:49 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so1453799pdj.25
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 07:29:48 -0700 (PDT)
In-Reply-To: <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 13:52 +0000, Christoph Lameter wrote:
> On Wed, 3 Apr 2013, Eric Dumazet wrote:
> 
> > I agree with you, I prefer &this_cpu_ptr(percpu_pointer)->field
> >
> > The offset is added after getting the address of the (percpu) base
> > object.
> 
> There are two offsets being added!


I was speaking of the offsetof(struct ..., field), not on the 'offset'
you think (the percpu one).

Thats why I prefer &this_cpu_ptr(percpu_pointer)->field

Its clearer for me, but thats a very minor issue.
