From: Greg Kroah-Hartman <greg@kroah.com>
Subject: Re: [PATCH] fix infoleak in wireless
Date: Tue, 3 May 2016 14:46:12 -0700
Message-ID: <20160503214612.GA13289@kroah.com>
References: <1462308013-6032-1-git-send-email-kjlu@gatech.edu>
 <1462308044.10444.19.camel@sipsolutions.net>
 <CABEk9YxqyBxnqOseJ3-d-aKxnREZBFt1z89nOjHf=DvNQy_hTw@mail.gmail.com>
 <20160503210052.GA23109@kroah.com>
 <CABEk9YwiqpP+Ahxax3AC7tbPcmpUQnrB-Nwsb4rixhVjcL4Crw@mail.gmail.com>
 <20160503213401.GB23469@kroah.com>
 <CABEk9YwmQt9bQb_KXgYRj=irq9-edtdOeANs7+Z4qZp1zmqpxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABEk9YwmQt9bQb_KXgYRj=irq9-edtdOeANs7+Z4qZp1zmqpxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A: http://en.wikipedia.org/wiki/Top_post
Q: Were do I find info about this thing called top-posting?
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
A: Top-posting.
Q: What is the most annoying thing in e-mail?

A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Tue, May 03, 2016 at 05:41:46PM -0400, Kangjie Lu wrote:
> You are right. But wouldn't it be more general/better if we initializ=
e the
> allocation at very beginning?
> To avoid information leaks, I think we are supposed to initialize all
> allocations properly if=A0
> we are not sure how they are used.

But the networking maintainers told you to fix the broken drivers
instead.  So please do that and send those patches to the correct
developers and mailing lists.

The fact that only 2 staging drivers got this wrong means that everyone
knows how to use this api properly, so I agree with the maintainers
here.

thanks,


greg k-h
