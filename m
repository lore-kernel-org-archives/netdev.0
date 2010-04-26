From: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch v2] bluetooth: handle l2cap_create_connless_pdu() errors
Date: Mon, 26 Apr 2010 15:27:52 -0300
Message-ID: <20100426182752.GA23633@vigoh>
References: <20100422123347.GA5265@vigoh>
 <20100426113627.GS29093@bicker>
 <20100426150919.GA12813@vigoh>
 <20100426.111259.112594696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	andrei.emeltchenko-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100426.111259.112594696.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [2010-04-26 11:12:59 -0700]:

> From: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
> Date: Mon, 26 Apr 2010 12:09:19 -0300
> 
> > Hi Dan,
> > 
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

My bad here. So I think we should pick the first version of the Dan's patch. 
It applies against bluetooth-testing right now and then against net-2.6 too.

Marcel, is that ok to you?

> 
> Marcel, please do whatever magic you need to so I can get this into
> Linus's tree as I did the rest of the ERR_PTR() fixes from Dan already.
> No reason to treat Bluetooth special and defer these fixes to -next.
> 
> Thanks.

-- 
Gustavo F. Padovan
http://padovan.org
