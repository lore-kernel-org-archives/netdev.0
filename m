From: david@lang.hm
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 19:45:33 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0908171942430.30426@asgard.lang.hm>
References: <20090814204305.GA31727@pengutronix.de> <4A89AC40.2040109@am.sony.com> <4A89DB15.6060101@am.sony.com> <20090817.180323.253692704.davem@davemloft.net> <4A8A0454.8000902@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, tim.bird@am.sony.com,
	r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755712AbZHRCqM@vger.kernel.org>
In-Reply-To: <4A8A0454.8000902@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Aug 2009, Rick Jones wrote:

> David Miller wrote:
>> I have card/switch combinations that take up to 10 seconds to
>> negotiate a proper link.
>
> Gotta love it when things adhere to specs...

the default on Cisco switches is to wait 30 seconds before fully enabling 
the port so that it can listen for spanning tree broadcasts.

for windows systems this doesn't cause any problems (they take long enough 
to boot), but for a tightly configured linux box it can be fully booted 
long before the switch decides to enable the port (for that matter, I have 
a bare-metal install process that takes about 90 seconds from hitting 
power, from a CD. I could probably speed things up by switching to USB 
boot media)

David Lang
