From: Tim Bird <tim.bird@am.sony.com>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 18:24:26 -0700
Message-ID: <4A8A02CA.7040305@am.sony.com>
References: <20090814204305.GA31727@pengutronix.de>	<4A89AC40.2040109@am.sony.com>	<4A89DB15.6060101@am.sony.com> <20090817.180323.253692704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758557AbZHRBZN@vger.kernel.org>
In-Reply-To: <20090817.180323.253692704.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tim Bird <tim.bird@am.sony.com>
> Date: Mon, 17 Aug 2009 15:35:01 -0700
> 
>> Tim Bird wrote:
>>> See the definitions of CONF_PRE_OPEN and CON_POST_OPEN
>>> in net/ipv4/ipconfig.c
>>>
>>> They are set to ridiculously long values.  In my experience,
>>> you can cut them down considerably with no dangerous side
>>> effects (but I haven't asked the network guys about the
>>> possible downsides).
>> It turns out that others have seen this delay.  Simon
>> Arlott recently posted a patch to make the delay avoidable
>> at boot time from the kernel command line.
>>
>> See http://patchwork.kernel.org/patch/31678/
> 
> "Rediculiously long" is a relative term.
No offense intended.  I could have phrased this
better.  The delays were a few orders of
magnitude longer than apparently needed, on my
embedded test systems with ethernet.  I didn't
try eliminating them completely, as in the Arlott patch.

1.5 seconds is a long time for me.  My bootup time budget for
the kernel ranges from 0.5 to 3.0 seconds, depending on the
product.

> I have card/switch combinations that take up to 10 seconds to
> negotiate a proper link.

What types of delays are these timeouts supposed to
cover?  Networking delays or hardware bring-up delays?
(Or both)?  If for networking delays, is this for all
types of networks, or just some (e.g. ones that create
virtual circuits)?

I'm trying to get a sense for whether the card/switch
combinations that would take this long would be encountered
in the types of embedded devices I code for.  (TVs, camcorders,
etc.)

>
> So what's there now is actually a quite agressive setting.
> 
> And BTW, discussions about stuff like this belong on
> netdev@vger.kernel.org, which has been added to the CC:

I was going to wait to see if this solved Robert's
problem, before widening the discussion.  But I'm happy
to find out more about these delays now.

Thanks,
 -- Tim

=============================
Tim Bird
Architecture Group Chair, CE Linux Forum
Senior Staff Engineer, Sony Corporation of America
=============================
