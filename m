From: Michael =?ISO-8859-1?Q?B=FCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 11:56:23 +0100
Message-ID: <1295261783.24530.3.camel@maggie>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
	 (sfid-20110117_114654_053644_FFFFFFFF84F9C750)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20110117_114654_053644_FFFFFFFF84F9C750)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-17 at 11:46 +0100, Jonas Gorski wrote: 
> Hello,
> 
> I am currently looking into adding support for the newer Broadcom
> BCM47xx/53xx SoCs. They require having HND/AI support, which probably
> means merging the current SSB code and the HND/AI code from the
> brcm80211 driver. Is anyone already working on this?
> 
> As far as I can see, there are two possibilities:
> 
> a) Merge the HND/AI code into the current SSB code, or
> 
> b) add the missing code for SoCs to brcm80211 and replace the SSB code with it.

Why can't we keep those two platforms separated?
Is there really a lot of shared code between SSB and HND/AI?

It's true that there's currently a lot of device functionality built
into ssb. Like pci bridge, mips core, extif, etc...
If you take all that code out, you're probably not left with anything.

So why do we need to replace or merge SSB in the first place? Can't
it co-exist with HND/AI?

-- 
Greetings Michael.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
