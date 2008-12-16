From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 02/12] net: infrastructure for hardware time
	stamping
Date: Tue, 16 Dec 2008 08:56:59 +0100
Message-ID: <1229414219.18038.241.camel@ecld0pohly>
References: <E1LCLNV-0001EW-CN@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org" <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1LCLNV-0001EW-CN-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-12-15 at 21:53 +0000, Herbert Xu wrote:
> Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> > @@ -305,6 +406,8 @@ struct sk_buff {
> >                                ipvs_property:1,
> >                                peeked:1,
> >                                nf_trace:1;
> > +       /* not all of the bits in optional are used */
> > +       __u8                    optional;
> >        __be16                  protocol;
> 
> You do reliase that this is going to grow the sk_buff by at least
> 4 bytes and not 1?

Yes. I should have been more explicit about that when talking about
"adding one byte". At least it's better than adding 8 bytes of
additional data, as in the previous patch.

I haven't checked it, but was told that sk_buff is already tightly
packed. It didn't look like there was a better place to put the byte
either.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
