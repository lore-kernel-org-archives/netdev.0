From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4/4] MCS7830 USB-Ether: resume _with_ working link, via
 .reset_resume support
Date: Wed, 03 Feb 2010 18:29:47 -0800 (PST)
Message-ID: <20100203.182947.188290610.davem@davemloft.net>
References: <20100131125842.GD13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd-r2nGTMty4D4@public.gmane.org, dhollis-yI4QWewtAp2DvotElmWtJA@public.gmane.org, pchang23-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andi-5+Cda9B46AM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100131125842.GD13435-p/qQFhXj4MHA4IYVXhSI5GHfThorsUsI@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Date: Sun, 31 Jan 2010 13:58:42 +0100

> ChangeLog:
> Implement .reset_resume support to retain a live network connection
> during suspend despite USB power loss.
> - rework operation to reference cached data in mcs7830_data and
>   netdev->dev_addr 
> - update netdev->dev_addr only in case new MAC was set successfully
> . Tests done:
>   . ethtool -d pre-/post-suspend: register values match
>   . running ssh session suspend, resume: works
>   . ifdown device, suspend, resume: works
>   . ifup, suspend, unplug, resume: WORKS (eth1 is removed, re-ifup of eth1
>     after card replug works)
>   . verified identical MAC in ifconfig post-resume
>     (ok, should be verified on network side to be fully certain...)
> 
> 
> Keywords: suspend resume network connection dead interface down
> 
> Signed-off-by: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>

Applied net-next-2.6
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
