From: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Thu, 28 Aug 2008 13:13:52 +0200
Message-ID: <200808281313.53163.bruno@thinktube.com>
References: <20080827013009.GA15781@tuxdriver.com> <200808281235.35449.bruno@thinktube.com> <1ba2fa240808280352q4a913c1cv33a6bc0998cdbcb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240808280352q4a913c1cv33a6bc0998cdbcb9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 28 August 2008 12:52:36 Tomas Winkler wrote:
> Do you know how the  TSF is actually synchronized from the HW perspective?

no, unfortuately i have no idea. also i should admit that we have problems 
with atheros hardware in that we don't know when the RX timestamp is taken 
exactly. this means our IBSS merge can't be 100% exact. but the usual case we 
need to catch is when the beacon TSF is much higher than the local TSF. 

i don't care about IBSS power-save right now.

> > with the same HW but it did not work any more - i didn't have the time to
> > investigate this issue...
>
> There is another IBSS bug that was introduced connected to rates maybe
> this is also your problem.. we have something in the pipe that should
> solve this.

good, i'll retest once you subitted the patch.

> Sure but if TSF is not adopted correctly and that's the case probably
> of most of the drivers under mac80211 then it makes
> worth.  Just need to be aware of this.

true, we need to find a way to support this hardware too...

bruno

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
