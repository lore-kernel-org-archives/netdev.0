From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Bug 98781] New: WWAN: TX bytes counter shows very huge
 impossible value
Date: Sat, 13 Jun 2015 08:33:39 -0700
Message-ID: <20150613083339.71d38d3d@urahara>
References: <20150526083857.78cb053b@urahara>
	<loom.20150613T021828-603@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin <kevin.padoa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36615 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbFMPdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 11:33:41 -0400
Received: by pdjm12 with SMTP id m12so42254613pdj.3
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 08:33:40 -0700 (PDT)
In-Reply-To: <loom.20150613T021828-603@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Jun 2015 00:28:58 +0000 (UTC)
Kevin <kevin.padoa@gmail.com> wrote:

> Stephen Hemminger <stephen <at> networkplumber.org> writes:
> 
> > 
> > 
> > Begin forwarded message:
> > 
> > Date: Sat, 23 May 2015 16:54:50 +0000
> > From: "bugzilla-daemon <at> bugzilla.kernel.org" <bugzilla-daemon <at>
> bugzilla.kernel.org>
> > To: "shemminger <at> linux-foundation.org" <shemminger <at>
> linux-foundation.org>
> > Subject: [Bug 98781] New: WWAN: TX bytes counter shows very huge
> impossible value
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=98781
> > 
> >             Bug ID: 98781
> >            Summary: WWAN: TX bytes counter shows very huge impossible
> >                     value
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 4.0.x
> >           Hardware: Intel
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: shemminger <at> linux-foundation.org
> >           Reporter: mm <at> superbash.de
> >         Regression: No
> > 
> > Since version 4.0.x the TX bytes counter of the WWAN module shows a weird
> > value.
> > 
> > Example:
> > 
> > $ > ifconfig wwan
> > 
> > wwan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
> >         inet xxx.xxx.xxx.xxx  netmask 255.255.255.252  broadcast
> > xxx.xxx.xxx.xxx
> >         inet6 xxxx::xxxx:xxxx:xxxx:xxxx  prefixlen 64  scopeid 0x20<link>
> >         ether xx:xx:xx:xx:xx:xx  txqueuelen 1000  (Ethernet)
> >         RX packets 19036  bytes 19190321 (18.3 MiB)
> >         RX errors 0  dropped 0  overruns 0  frame 0
> >         TX packets 15874  bytes 43228847574631 (39.3 TiB)
> >         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> > 
> > 39.3 TiB - wow, absolutely not true
> > 
> > The WWAN is used as bridge to my internet provider (LTE usb stick)
> > 
> > I use the counter to control the traffic. It's only the TX counter, the RX
> > works ok.
> > 
> I have exactly the same issue, exhibited when upgrading (n-1) kernel on
> Ubuntu Vivid 15.04 from 3.17.x:
> 
> Linux uranis 3.19.0-20-generic #20-Ubuntu SMP Fri May 29 10:10:47 UTC 2015
> x86_64 x86_64 x86_64 GNU/Linux
> 
> wwan0     Link encap:Ethernet  HWaddr 26:03:a9:e3:88:2e  
>           inet addr:41.150.225.132  Bcast:41.150.225.135  Mask:255.255.255.248
>           inet6 addr: fe80::2403:a9ff:fee3:882e/64 Scope:Link
>           UP BROADCAST RUNNING NOARP MULTICAST  MTU:1500  Metric:1
>           RX packets:3366 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:3497 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:1459963 (1.4 MB)  TX bytes:15019500985395 (15.0 TB)
> 
> Kernel internal or module (driver) bug, shows up everywhere including
> 'system monitor'. This problem has come up a few years back and was solved,
> but seems to be back again...
> 
> Any ideas on fix ?

What driver is this device? 
