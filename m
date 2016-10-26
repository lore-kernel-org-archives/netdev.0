From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] netlink: Add nla_memdup() to wrap kmemdup()
 use on nlattr
Date: Wed, 26 Oct 2016 12:18:47 +0200
Message-ID: <1477477127.4059.27.camel@sipsolutions.net>
References: <2d0864c85200f1b42b1ebceee7c2dc60fe29f26a.1477471562.git.tgraf@suug.ch>
         <1477472376.4059.23.camel@sipsolutions.net>
         <20161026095238.GB16590@pox.localdomain>
         (sfid-20161026_115243_626103_4ED9717E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161026095238.GB16590-4EA/1caXOu0mYvmMESoHnA@public.gmane.org> (sfid-20161026_115243_626103_4ED9717E)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-26 at 11:52 +0200, Thomas Graf wrote:
> On 10/26/16 at 10:59am, Johannes Berg wrote:
> > 
> > 
> > > 
> > >  /**
> > > + * nla_memdup - duplicate attribute memory (kmemdup)
> > > + * @src: netlink attribute to duplicate from
> > > + * @gfp: GFP mask
> > 
> > Actually, is there any point in passing a GFP mask? None of the
> > current
> > users need it, and it seems fairly unlikely to be needed since this
> > is
> > typically used on the netlink input path, where you surely
> > shouldn't
> > need GFP_ATOMIC or so?
> 
> I'm fine either way. I didn't want to make assumptions which need
> later changes. It's not hurting either and the function prototype
> is very small.

Yeah, I don't really care much - just wondered.

johannes
