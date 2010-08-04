From: Greg KH <greg@kroah.com>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (after using openvpn) (was Re: sysfs bug when using tun with network
 namespaces)
Date: Wed, 4 Aug 2010 14:46:18 -0700
Message-ID: <20100804214618.GA6289@kroah.com>
References: <loom.20100708T183152-326@post.gmane.org>
 <20100709235744.GA12752@kroah.com>
 <20100710101540.2799c9ef@xenia.leun.net>
 <20100710140800.GA20424@kroah.com>
 <20100710165208.59272ae6@xenia.leun.net>
 <20100710235323.5336f627@xenia.leun.net>
 <20100711192939.1c25dcaf@xenia.leun.net>
 <20100804153543.56f6ecad@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Michael Leun <lkml20100708@newton.leun.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35841 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007Ab0HDVqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 17:46:50 -0400
Content-Disposition: inline
In-Reply-To: <20100804153543.56f6ecad@xenia.leun.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 03:35:43PM +0200, Michael Leun wrote:
> Hi,
> 
> On Sun, 11 Jul 2010 19:29:39 +0200
> Michael Leun <lkml20100708@newton.leun.net> wrote:
> 
> [...]
> > Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for lo to
> > become free. Usage count = 3 [repeated]
> > 
> > Now one might say it is fault of openvpn (used OpenVPN 2.1_rc20
> > i586-suse-linux - the one in openSuSE 11.2 package), openvpn didn't
> > close some ressource and ssh does fine.
> > 
> > But: should'nt kernel clean up after process when it exits?
> > And/or: Should'nt kernel clean up if last process in network namespace
> > exits - there is nothing left which might use that interface?!
> > 
> > Greg KH <greg@kroah.com> wrote:
> > 
> > > Yes, you are correct.  Care to resend all of this to the
> > > network-namespace developer(s) and the netdev mailing list so that
> > > the correct people are notified so they can fix it all?
> > 
> > [X] done - hopefully, cannot find a particular network namespace
> > developer in MAINTAINERS or source files. If such a one exists, please
> > forward.
> 
> Did'nt work. Got no reaction from network mailinglist at all and bug
> still is in 2.6.35.

Eric, here's a bug with the network namespace stuff, care to work on
resolving it?

thanks,

greg k-h
