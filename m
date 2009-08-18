From: David Miller <davem@davemloft.net>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 18:03:23 -0700 (PDT)
Message-ID: <20090817.180323.253692704.davem@davemloft.net>
References: <20090814204305.GA31727@pengutronix.de>
	<4A89AC40.2040109@am.sony.com>
	<4A89DB15.6060101@am.sony.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: tim.bird@am.sony.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758392AbZHRBDN@vger.kernel.org>
In-Reply-To: <4A89DB15.6060101@am.sony.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Bird <tim.bird@am.sony.com>
Date: Mon, 17 Aug 2009 15:35:01 -0700

> Tim Bird wrote:
>> See the definitions of CONF_PRE_OPEN and CON_POST_OPEN
>> in net/ipv4/ipconfig.c
>> 
>> They are set to ridiculously long values.  In my experience,
>> you can cut them down considerably with no dangerous side
>> effects (but I haven't asked the network guys about the
>> possible downsides).
> 
> It turns out that others have seen this delay.  Simon
> Arlott recently posted a patch to make the delay avoidable
> at boot time from the kernel command line.
> 
> See http://patchwork.kernel.org/patch/31678/

"Rediculiously long" is a relative term.

I have card/switch combinations that take up to 10 seconds to
negotiate a proper link.

So what's there now is actually a quite agressive setting.

And BTW, discussions about stuff like this belong on
netdev@vger.kernel.org, which has been added to the CC:
