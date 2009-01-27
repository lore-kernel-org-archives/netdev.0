From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: hardware time stamping with optional structs in data area
Date: Mon, 26 Jan 2009 17:22:02 -0800 (PST)
Message-ID: <20090126.172202.261408793.davem@davemloft.net>
References: <1232532457.7829.19.camel@ecld0pohly>
	<20090125.210442.129666692.davem@davemloft.net>
	<1233002392.23161.6.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1233002392.23161.6.camel@pohly-MOBL>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Mon, 26 Jan 2009 21:39:52 +0100

> On Mon, 2009-01-26 at 07:04 +0200, David Miller wrote:
> > Just consolidate the array into a direct conversion table.  You only
> > have 2 bits defined so you only need an array of 4 entries.  Pass the
> > optional flag bits directly in as the index of that table.
> 
> How can I get some code executed during the initialization of the IP
> stack which initializes the table, before any sk_buff gets allocated?
> 
> The content is constant, but writing it down as static initializers
> using just preprocessor macros would be difficult and/or ugly - that's
> why I haven't done it already.

It's 4 entries... really.  You can initialize them simply, perhaps
with some fancy macro used by the initializers.
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
