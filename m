From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 16:58:01 +0300
Message-ID: <542AB6E9.9000907@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>,
	<tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<nm@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<linux-omap@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:40273 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbaI3N6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 09:58:30 -0400
In-Reply-To: <20140930135226.GO1325@katana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 04:52 PM, Wolfram Sang wrote:
> 
>>>> +- ti,raminit-syscon	: Handle to system control region that contains the
>>>> +			  RAMINIT register. If specified, the second memory resource
>>>> +			  in the reg property must index into the RAMINIT
>>>> +			  register within the syscon region
>>>
>>> There seems to be a simple "syscon" property these days.
>>
>> I had used plain "syscon" in the earlier revisions but was asked to make it a TI specific
>> property since only TI uses this mechanism.
> 
> I see, when was that? Currently, it looks messy :( Grepping through the
> dts files in 3.17-rc7, I see that bcm7445 uses "syscon" and variants
> with prefixes, STE uses it, too. Samsung uses "samsung,syscon-phandle",
> st uses "st,syscon"...
> 
> The MACID readout patches for AM335x (just applied right now) also use
> "syscon": https://patchwork.ozlabs.org/patch/394289/
> 
> I'd vote for a generic "syscon" to be OK, yet I guess the DT maintainers
> will have the final word.

Now that I actually checked, it was never just "syscon" but just without the "ti" vendor prefix.
Sorry for the misinformation.

As just TI is using this out of band RAMINIT mechanism, should it be "ti,syscon" or just "syscon"?

cheers,
-roger
