From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch v2] bluetooth: handle l2cap_create_connless_pdu() errors
Date: Tue, 27 Apr 2010 04:05:26 +0200
Message-ID: <1272333926.22838.116.camel@localhost.localdomain>
References: <20100422123347.GA5265@vigoh> <20100426113627.GS29093@bicker>
	 <20100426150919.GA12813@vigoh>
	 <20100426.111259.112594696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	andrei.emeltchenko-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100426.111259.112594696.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > * Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2010-04-26 13:36:27 +0200]:
> > 
> >> l2cap_create_connless_pdu() can sometimes return ERR_PTR(-ENOMEM) or
> >> ERR_PTR(-EFAULT).
> >> 
> >> Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> ---
> >> In v2 I wrote the patch on top of Gustavo Padovon's devel tree
> 
> This is the kind of bug that could cause a crash if the path actually
> executes.
> 
> Therefore it tires me that that submitter was told to regenerate this
> patch against some devel tree that is -next bound, when in fact this
> is the kind of fix that warrants inclusion right now into net-2.6
> 
> Marcel, please do whatever magic you need to so I can get this into
> Linus's tree as I did the rest of the ERR_PTR() fixes from Dan already.
> No reason to treat Bluetooth special and defer these fixes to -next.

my bad here. I looked at the patch and thought it was only an issue
inside the development tree. So was letting Gustavo sort this out. You
are 100% right, this needs to be fixed right away. If you wanna take
this directly, then

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel
