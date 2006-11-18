From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Bug#396185: sky2 freezes in 2.6.17-2-686. Maintainer confirms that it should be fixed in 2.6.19-git tree.
Date: Sat, 18 Nov 2006 14:25:28 +0300
Message-ID: <20061118112527.GA25624@2ka.mipt.ru>
References: <20061031073030.6658.11274.reportbug@kano.factory.vocord.ru> <20061031085716.GW13178@baikonur.stro.at> <20061031093051.GA3323@2ka.mipt.ru> <20061031093455.GX13178@baikonur.stro.at> <20061031094424.GA19052@2ka.mipt.ru> <20061116173532.GA10653@2ka.mipt.ru> <20061116093821.318efbe6@freekitty> <20061118112134.GI4213@nancy>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Stephen Hemminger <shemminger@osdl.org>, 396185@bugs.debian.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36565 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1756289AbWKRLZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Nov 2006 06:25:58 -0500
To: maximilian attems <maks@sternwelten.at>
Content-Disposition: inline
In-Reply-To: <20061118112134.GI4213@nancy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 18, 2006 at 12:21:34PM +0100, maximilian attems (maks@sternwelten.at) wrote:
> > > > > > > > Bug was filled against 2.6.17-9, but was fixed in recent git (2.6.19-rc3), probably also
> > > > > > > > fixed in 2.6.18.1
> > > > > > > > 
> > > > > > > > Here is link to discussion:
> > > > > > > > http://marc.theaimsgroup.com/?l=linux-netdev&m=116227512815783&w=2
> > > > > > > > 
> > > > > > > 
> > > > > > > can you try the linux-image 2.6.18, they are in unstable
> > > > > > > and the etch release images.
> > > 
> > > 2.6.18-1-686 kernel still allows to freeze sky2.
> > 
> > Fix didn't go in until 2.6.18.2
> 
> fix is in the 2.6.18-2-686 linux image, you'd better update
> your test box.

Just for clarification: there are at least two bugs described - one in
the above link, and this new one. The former could only be fixed by
reboot, the latter - by rmmod/modprobe sequence. The former had special
info in dmesg, the latter does not.

Hopefully they both are fixed in 2.6.18-2.
I will set it up as soon as time permits (it is my main desktop, which
is rarely turned off) and report if problem still persists.

> thanks
>  
> -- 
> maks

-- 
	Evgeniy Polyakov
