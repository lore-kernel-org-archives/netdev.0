From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 17:58:16 +0200
Message-ID: <533D8518.1010306@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de> <533D8207.2050108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533D8207.2050108@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.04.2014 17:45, schrieb Sebastian Hesselbarth:

>
> I will try to reproduce it and if I hit it, will do a bisect to find
> (and fix) the offending patch.
>
>> I have better ways to waste my time.
>
> Like writing workarounds instead of fixing bugs?

Sure. If I would try to fix (or even describe) every bug in the kernel I 
already know about, I would never have time to do anything else.

Besides that you still try to ignore, that I didn't know at first that 
it's a workaround at all. Especially after I've discovered that the 
reset is the place where things are failing. Otherwise I wouldn't have 
sent the patch (which I know NOW that it just is a workaround).

Alexander Holler
