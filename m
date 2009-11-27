From: Andreas Schultz <aschultz@warp10.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Fri, 27 Nov 2009 10:11:47 +0100
Message-ID: <db81a9a20911270111j2ddaf967od3d7467e0295ba36@mail.gmail.com>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tproxy@lists.balabit.hu, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:34292 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbZK0JLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 04:11:42 -0500
Received: by ewy19 with SMTP id 19so1204171ewy.21
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2009 01:11:47 -0800 (PST)
In-Reply-To: <1259310417.3809.5.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Nov 27, 2009 at 9:26 AM, KOVACS Krisztian <hidden@balabit.hu> wrote:
> Hi,
>
> On Thu, 2009-11-26 at 18:19 +0100, Andreas Schultz wrote:
>> Hi,
>>
>> git bisect shows that TPROXY has been broken by commit
>> f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0, [PATCH] net: Fix RPF to work
>> with policy routing
>>
>> I had a look at the patch, and it seems logical that this would break TPROXY.
>
> Indeed, that's a good catch. If this is indeed the problem you should be
> able to work it around by disabling rpfilter on the ingress interface.
> Does it work that way?

That was my first guess also. I disabled rp_filter on all interfaces
and it had no impact. So far, only reverting that patch has solved the
problem.

Andreas
