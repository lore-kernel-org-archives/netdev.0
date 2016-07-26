From: alexmcwhirter@triadic.us
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Tue, 26 Jul 2016 14:15:55 -0400
Message-ID: <66636d159da5342b1387035fbcfe0d35@triadic.us>
References: <201607260457.u6Q4v3pM010082@sdf.org>
 <2589898.190WVraD7Z@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Curry <rlwinm@sdf.org>, Al Viro <viro@zeniv.linux.org.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2589898.190WVraD7Z@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-07-26 09:59, Christian Lamparter wrote:
> Thanks, I gave the program a try with my WNDA3100 and a WN821N v2 
> devices.
> I did not see any corruptions in any of the tests though. Can you tell 
> me
> something about your wireless network too? I would like to know what 
> router
> and firmware are you using? Also important: what's your wireless 
> configuration?
> (WPA?, CCMP or TKIP? HT40, HT20 or Legacy rates? ...)
> 
> Probably the quickest and easiest way to get that information is by 
> running
> the following commands as root, when you are connected to your wifi 
> network
> and post the results:
> # iw dev wlan0 link
> # iw dev wlan0 scan dump
> 
> (You can of course remove your device's MACs, but please do it 
> consistently).
> 
> Regards,
> Christian

I wonder if this is something that is only affecting certain NIC's? For 
example, it see this issue on sun4u boxes with tigon3 and hme 
interfaces. But on my sun4v boxes that have e1000 interfaces everything 
works fine.
