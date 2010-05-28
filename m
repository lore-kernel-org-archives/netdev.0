From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH] netdev/fec: fix ifconfig eth0 down hang issue
Date: Fri, 28 May 2010 23:13:48 +0800
Message-ID: <4BFFDDAC.7000909@canonical.com>
References: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com> <20100528144506.GB13777@pengutronix.de>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, afleming@gmail.com, s.hauer@pengutronix.de,
	gerg@uclinux.org, amit.kucheria@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100528144506.GB13777@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/28/2010 10:45 PM, Wolfram Sang wrote:
> On Fri, May 28, 2010 at 05:08:05PM +0800, Bryan Wu wrote:
>> BugLink: http://bugs.launchpad.net/bugs/559065
>>
>> In fec open/close function, we need to use phy_connect and phy_disconnect
>> operation before we start/stop phy. Otherwise it will cause system hang.
>>
>> Only call fec_enet_mii_probe() in open function, because the first open
>> action will cause NULL pointer error.
>>
>> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
> 
> We use this patch for 1 month now and didn't encounter any flaws so far.
> 
> Tested-by: Wolfram Sang <w.sang@pengutronix.de>
> 
> Oops, too late... well, one for the comfortable feeling ;)
> 

Thanks a lot, Wolfram. You are real helpful here.
Because my babbage board has broken for several weeks, I don't have hardware to
test my FEC patches.

The performance drop issue still hangs in my brain. As soon as I have a new
patch, could you please help to test? Or do you guys found any performance drop
solution on your hardware? IIRC, you reported similar issue as us.

Best regards,
-- 
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer    +86.138-1617-6545 Mobile
Ubuntu Kernel Team | Hardware Enablement Team
Canonical Ltd.      www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
