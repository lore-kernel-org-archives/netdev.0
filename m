From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Mon, 6 Jul 2015 21:44:06 +0200
Message-ID: <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
 <21611.1436179798@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21611.1436179798@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-07-06 12:49 GMT+02:00  <Valdis.Kletnieks@vt.edu>:
> On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
>> Add option to disable any reply not related to a listening socket,
>> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
>> Also disables ICMP replies to echo request and timestamp.
>> The stealth mode can be enabled selectively for a single interface.
>
> A few notes.....
>
> 1) Do you have an actual use case where an iptables '-j DROP' isn't usable?

If you mean using a default DROP policy and allowing only the traffic
do you want,
then the use case is where the port can change at runtime and you may not want
to update the firewall every time


> 2) You *do* realize that this isn't anywhere near sufficient in order
> to actually make your machine "invisible", right?  (Hint: What *other*
> packets can be sent to a machine to provoke a response?)

Other than ICMP, UDP and TCP excluding open TCP/UDP ports?

> 3) At least my copy had massive whitespace damage, where all the tab characters
> appear to have evaporated....

Sorry, I was using git sendemail first, but I got a security error from gmail,
so I copied/pasted the patch in gmail which corrupted it

-- 
Matteo Croce
OpenWrt Developer
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 CHAOS CALMER
 -----------------------------------------------------
  * 1 1/2 oz Gin            Shake with a glassful
  * 1/4 oz Triple Sec       of broken ice and pour
  * 3/4 oz Lime Juice       unstrained into a goblet.
  * 1 1/2 oz Orange Juice
  * 1 tsp. Grenadine Syrup
 -----------------------------------------------------
