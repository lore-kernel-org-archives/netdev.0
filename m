From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Tue, 18 Sep 2012 08:15:09 +0200
Message-ID: <20120918061509.GB2294@minipsycho.orion>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
 <20120917091214.5cd9b0f5@nehalam.linuxnetplumber.net>
 <20120917204724.GA1749@minipsycho.orion>
 <175CCF5F49938B4D99B2E3EF7F558EBE1B63898F0B@SC-VEXCH4.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mirko Lindner <mlindner@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <175CCF5F49938B4D99B2E3EF7F558EBE1B63898F0B@SC-VEXCH4.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Sep 18, 2012 at 02:38:52AM CEST, mlindner@marvell.com wrote:
>>Mon, Sep 17, 2012 at 06:12:14PM CEST, shemminger@vyatta.com wrote:
>>>On Mon, 17 Sep 2012 17:10:17 +0200
>>>Jiri Pirko <jiri@resnulli.us> wrote:
>>>
>>>> In my case I have following problem. sky2_set_multicast() sets registers
>>>> GM_MC_ADDR_H[1-4] correctly to:
>>>> 0000 0800 0001 0410
>>>> However, when adapter gets link and sky2_link_up() is called, the values
>>>> are for some reason different:
>>>> 0000 0800 0016 0410
>>>
>>>Rather than papering over the problem, it would be better to
>>>trace back what is setting those registers and fix that code.
>
>>Yes, I did that. No code at sky2.[ch] is writing to this registers other
>>than sky2_set_multicast() and sky2_gmac_reset() (I hooked on sky2_write*()).
>>So I strongly believe this is a HW issue (maybe only issue of my revision
>>"Yukon-2 EC chip revision 2")
>
>I would like to check the registers as soon as I'm back in my office next week and report my findings.

Okay, I'll wait for you. If you need more info from my side, please do
not hesitate to ask. Thanks!

>Could you also please check the hint from Stephen?
