From: Karsten =?iso-8859-1?q?K=F6nig?= <remur@gmx.net>
Subject: Re: [Bugme-new] [Bug 14711] New: usbnet ax88172 mac address change broken
Date: Tue, 2 Feb 2010 23:21:00 +0100
Message-ID: <201002022321.00177.remur@gmx.net>
References: <bug-14711-10286@http.bugzilla.kernel.org/> <20091203133845.4977551c.akpm@linux-foundation.org>
Reply-To: remur@gmx.net
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, linux-usb@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:60113 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756861Ab0BBW1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 17:27:38 -0500
In-Reply-To: <20091203133845.4977551c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No one around to tackle this?
In any case it should reject the MAC adress change as unsupported

Thanks,
Karsten

Am Donnerstag, 3. Dezember 2009 22:38:45 schrieb Andrew Morton:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 1 Dec 2009 15:41:10 GMT
> 
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=14711
> >
> >            Summary: usbnet ax88172 mac address change broken
> >            Product: Drivers
> >            Version: 2.5
> >     Kernel Version: 2.6.31rc8
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: remur@gmx.net
> >         Regression: No
> >
> >
> > When changing the MAC address on a NETGEAR FA120 (because an old one is
> > registered with my provider) the replies to the traffic don't reach the
> > system anymore, the NIC is dropping them, putting the NIC into promiscous
> > mode will show they are properly replied to.
> >
> > Searching around I found this patch from the openBSD folks
> > http://www.mail-archive.com/misc@openbsd.org/msg76418.html
> > http://www.openbsd.org/cgi-bin/cvsweb/src/sys/dev/usb/if_axe.c.diff?r1=1.
> >91;r2=1.92
> >
> > Looks like it is not working with the ax88172, but only with newer
> > models. Still an error message would be nice when setting another
> > physical address
> 
> It would be nice if some asix-competent person could take a look at porting
> that openbsd patch across, see if it fixes Karsten's hardware.
> 
