From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: Gentle Guide to the Network Stack
Date: Thu, 19 Jun 2008 14:01:07 +0300
Message-ID: <d0383f90806190401n2c54bc5cl4e72dd65f6c64517@mail.gmail.com>
References: <200806171105.23069.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Olaf Kirch" <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:40296 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755961AbYFSLBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:01:11 -0400
Received: by fg-out-1718.google.com with SMTP id 19so358161fgg.17
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:01:07 -0700 (PDT)
In-Reply-To: <200806171105.23069.okir@lst.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
- This Linux network stack paper is a good and blessed initiative, and
may be certailnly
helpful to developers.

  I hope to see more of it in th future !

question:
What do you mean by :
"current kernels allocate these in as single entity named struct sockalloc,"
chapter 6 (page 19).

I grepped for:
struct sockalloc and  struct sock_alloc under the kernel tree (git 2.6
netdev tree)
and could not find such a thing.

Regards,
Ian




On Tue, Jun 17, 2008 at 12:05 PM, Olaf Kirch <okir@lst.de> wrote:
> Hi all,
>
> I started putting together a paper on the Linux network stack,
> focusing on how things fit together, and help relative beginners
> understand the machinery, rather than giving a full-blown highly
> detailed cross reference (which would be outdated more quickly
> than you can re-run latex anyway :-)
> I intend to release it under the GPL or GNU FDL or similar license -
> I haven't fully made up my mind yet on what works best.
>
> You can find the first couple of pages at
> http://oss.oracle.com/~okir/network/paper.pdf
>
> I'd be very interested in general feedback on the approach taken,
> the level of detail and such. In case I missed the fact that
> someone else is currently doing the same, please let me know, too.
>
> Cheers,
> Olaf
> --
> Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
> okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
