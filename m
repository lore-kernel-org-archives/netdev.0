From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256
 dev_watchdog+0x1f2/0x200()
Date: Sun, 5 Feb 2012 14:59:13 -0800
Message-ID: <20120205145913.194746473361e324bda1eb4a@gmail.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com>
	<4F2F0065.9040909@lwfinger.net>
	<20120205222141.GA26223@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120205222141.GA26223@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 5 Feb 2012 23:21:41 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Larry Finger <Larry.Finger@lwfinger.net> :
> > On 02/05/2012 03:40 PM, Justin P. Mattock wrote:
> > >
> > >this showed up as I woke the machine up from suspend. machine is connected
> > >I just see networkmanager constantly spinning trying to connect then telling me
> > >the wired network is not connected(even though its just wireless that I have).
> 
> [ 1273.447349] r8169 0000:06:00.0: Refused to change power state, currently in D3
> [ 1273.571024] psmouse serio1: elantech: retrying ps2 command 0xf8 (2).
> [ 1273.656709] r8169 0000:06:00.0: eth0: link up
>                                          ^^^^^^^
> 
> Justin, you did not ever connect a cable, did you ?

nope! was using wireless the whole time. 

> 
> [...]
> > The error clearly comes from r8169, not from ath9k. If you unload
> > r8169 before suspending, does this still happen? My suspicion is
> > that NM is getting confused.
> 
> It could hide the problem but the D3 + link up messages are nonetheless
> a bit unexpected.
> 
> > P.S. Unless it happens with just the ath9k active, this ML is likely
> > not the correct one.
> 
> Yes, please Cc: netdev@vger.kernel.org + me instead.
> 
> Thanks.
> 
> -- 
> Ueimor

removed linux-wireless and added netdev to the cc's
will monitor this and report anything that shows up.

-- 
Justin P. Mattock <justinmattock@gmail.com>
