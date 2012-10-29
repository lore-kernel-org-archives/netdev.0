From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Information about napi_struct and net_device
Date: Sun, 28 Oct 2012 18:09:14 -0700
Message-ID: <20121028180914.5f74ae81@nehalam.linuxnetplumber.net>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52783 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab2J2BKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 21:10:05 -0400
In-Reply-To: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Oct 2012 18:18:39 +0200
Javier Domingo <javierdo1@gmail.com> wrote:

> Hello,
> 
> I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
> facilities, and I have found that there have been lots of changes in
> networking. Now the drivers are all by vendor, and more important,
> net_device is not used always, as napi_struct took its place.
> 
> I have asked in #kernel but no one answered me, so I subscribed here.
> Is there any place I can read about how is it now designed the use of
> napi_struct and net_device? I have found a presentation[1] about how
> networking was changing etc, and I wondered if there is anything more
> precise about how it is actually implemented.
> 
> I understand a little why napi_struct, but don't really know much
> about the change,
> 
> Hope someone can help me,
> 
> Javier Domingo
> 
> 
> [1]: http://vger.kernel.org/~davem/davem_nyc09.pdf
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

First, off put your driver upstream. The kernel developers do not care
about drivers not in the tree. They can wither up and die.

Second, learn to look in the right place.
  http://lwn.net/Articles/244640/
