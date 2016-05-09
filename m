From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: IPv6: proxy_ndp to a network range
Date: Mon, 9 May 2016 16:51:10 +0200
Message-ID: <20160509145109.GB7267@omega>
References: <31ff66eb-38bd-0186-9e81-0543f0558323@zytor.com>
 <20160509083903.GA2462@omega>
 <A2319CD4-6907-4B21-A4DD-03CCA38328FA@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37739 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcEIOvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 10:51:14 -0400
Received: by mail-wm0-f54.google.com with SMTP id a17so191713720wme.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 07:51:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <A2319CD4-6907-4B21-A4DD-03CCA38328FA@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, May 09, 2016 at 01:46:13AM -0700, H. Peter Anvin wrote:
> On May 9, 2016 1:39:08 AM PDT, Alexander Aring <alex.aring@gmail.com> wrote:
> >Hi,
> >
> >On Mon, May 09, 2016 at 01:06:51AM -0700, H. Peter Anvin wrote:
> >> Hello,
> >> 
> >> There currently doesn't seem to be any support for proxy_ndp of a
> >whole
> >> network mask, as IPv4 proxy_arp seems to permit.
> >> 
> >> a) Am I actually correct in this, or am I just missing something
> >important?
> >> 
> >> b) Is there a technical reason for this, or is it just a limitation
> >of the
> >> current implementation?
> >> 
> >
> >So far I know you can do this with the ndppd [0] userspace tool which
> >listen
> >NS/NA messages and do the ip -6 neigh add proxy for you.
> >
> >- Alex
> >
> >[0] https://github.com/DanielAdolfsson/ndppd
> 
> Sure, but it seems like a workaround for something that ought to be simpler?

I don't know if there exists a simpler way, but I would also be
interested into that.

There are some people @linux-wpan which wants to plugin an ethernet cable
and everything works out of the box to access the 6LoWPAN network over
the ethernet connection without doing routing setup stuff.

"ndppd" was on my list to test for realize such setup. :-)

---

For the simpler solution do you want to move the actually mechanism what
"ndppd" does into the kernel?

- Alex
