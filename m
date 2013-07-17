From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Wed, 17 Jul 2013 10:54:49 -0700
Message-ID: <1374083689.6097.19.camel@edumazet-glaptop>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	 <1372799622.4979.22.camel@edumazet-glaptop>
	 <CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	 <CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
	 <1372950494.4979.97.camel@edumazet-glaptop>
	 <CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
	 <CADCFf2jzs+41uKD9RjotXpqSRDoJnSFY90LVKt2UeQfUF05Wrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fernando Soto <fernando.soto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48424 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934115Ab3GQRyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 13:54:51 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so2149692pbb.8
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 10:54:50 -0700 (PDT)
In-Reply-To: <CADCFf2jzs+41uKD9RjotXpqSRDoJnSFY90LVKt2UeQfUF05Wrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-17 at 09:19 -0400, Fernando Soto wrote:
> Hi Eric,
> 
> Just to let you know that I have performed same tests with 3.4.52 and
> it works fine.
> Kernel 3.10 had another issue that prevented me from running the same
> tests: network dies as soon as I launch iperf - no kernel errors, but
> it simply doesn't work.
> I'll stick to 3.4.52. Thanks for your help.

This might be relevant : http://patchwork.ozlabs.org/patch/259596/
