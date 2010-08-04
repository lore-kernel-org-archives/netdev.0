From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (after using openvpn) (was Re: sysfs bug when using tun with network
 namespaces)
Date: Wed, 4 Aug 2010 15:35:43 +0200
Message-ID: <20100804153543.56f6ecad@xenia.leun.net>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: greg@kroah.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100711192939.1c25dcaf@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, 11 Jul 2010 19:29:39 +0200
Michael Leun <lkml20100708@newton.leun.net> wrote:

[...]
> Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo to
> become free. Usage count = 3 [repeated]
> 
> Now one might say it is fault of openvpn (used OpenVPN 2.1_rc20
> i586-suse-linux - the one in openSuSE 11.2 package), openvpn didn't
> close some ressource and ssh does fine.
> 
> But: should'nt kernel clean up after process when it exits?
> And/or: Should'nt kernel clean up if last process in network namespace
> exits - there is nothing left which might use that interface?!
> 
> Greg KH <greg@kroah.com> wrote:
> 
> > Yes, you are correct.  Care to resend all of this to the
> > network-namespace developer(s) and the netdev mailing list so that
> > the correct people are notified so they can fix it all?
> 
> [X] done - hopefully, cannot find a particular network namespace
> developer in MAINTAINERS or source files. If such a one exists, please
> forward.

Did'nt work. Got no reaction from network mailinglist at all and bug
still is in 2.6.35.

-- 
MfG,

Michael Leun
