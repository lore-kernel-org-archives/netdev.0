From: Dan Williams <dcbw@redhat.com>
Subject: Re: dscape doesn't auto associate
Date: Wed, 24 Jan 2007 07:51:19 -0500
Message-ID: <1169643079.2807.8.camel@localhost.localdomain>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
	 <200701231843.05902.flamingice@sourmilk.net>
	 <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	netdev <netdev@vger.kernel.org>
To: Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbXAXMst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 07:48:49 -0500
In-Reply-To: <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-23 at 20:48 -0500, Jon Smirl wrote:
> On 1/23/07, Michael Wu <flamingice@sourmilk.net> wrote:
> > On Tuesday 23 January 2007 18:23, Jon Smirl wrote:
> > > I have to manually associate the dscape stack with my AP. Is this way
> > > the code is supposed to work? Everything works ok after the manual
> > > association.
> > >
> > It's suppose to work with wpa_supplicant which sets every parameter.
> > NetworkManager uses wpa_supplicant so configuration can be pretty easy.
> 
> Something isn't working right with NetworkManager for me. I have both
> zd1211 and rt2570 devices and neither will start automatically but I
> can get the going manually.
> 
> I'll try running NetworkManager in the debugger and see if I can
> figure out what is failing. NetworkManager is working ok for me on
> non-dscape devices.
> 
> As for running as an AP:
> rt2570 will start in Master mode
> zd1211 refused to set Master mode
> 
> zd1211 has this problem too:
> Error for wireless request "Set Encode" (8B2A) :
>     SET failed on device wlan1 ; Invalid argument.

If you get this error in the _NM_ logs, it's likely just trying to clear
out the key, and you can probably ignore it.  If you get this error from
wpa_supplicant, it's probably a driver issue.

Can you send me some logs privately?  I think SUSE directs the NM logs
somewhere like /var/log/NetworkManager.log.  Stop NM as a service, get
root, then "NetworkManager --no-daemon" and redirect the output to a
file if you don't want to track down the logs themselves.

Cheers,
Dan

> > If you really want to manually associate, set the channel, (e)ssid, and
> > encryption (if any) in any order, and then set the bssid (ap) last. There
> > will be patches to allow association by just setting the SSID for backwards
> > compatibility with configuration scripts.
> >
> > -Michael Wu
> >
> >
> >
> 


