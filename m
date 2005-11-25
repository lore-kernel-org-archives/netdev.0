From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: ipw2200 in 2.6.15-rc2-git4 warns about improper NETDEV_TX_BUSY retcode
Date: Fri, 25 Nov 2005 11:59:20 +0100
Message-ID: <5a4c581d0511250259i3e412c92i57a0bfe82144c81a__24157.180536031$1132916711$gmane$org@mail.gmail.com>
References: <5a4c581d0511241538s496adee9s249cd038501545c9@mail.gmail.com>
	 <1132889013.24413.5.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zhu Yi <yi.zhu@intel.com>
In-Reply-To: <1132889013.24413.5.camel@debian.sh.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 11/25/05, Zhu Yi <yi.zhu@intel.com> wrote:
> On Fri, 2005-11-25 at 00:38 +0100, Alessandro Suardi wrote:
> > Dell Latitude D610, FC4 base distro, kernel is:
> >
> > [asuardi@sandman ~]$ cat /proc/version
> > Linux version 2.6.15-rc2-git4 (asuardi@sandman) (gcc version 4.0.1
> > 20050727 (Red Hat 4.0.1-5)) #2 Fri Nov 25 00:15:46 CET 2005
> >
> > Onboard wireless card as detected by kernel is:
> > ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, git-1.0.8
> >
> >  and I placed the 2.4 firmware from sourceforge.net in /lib/firmware.
> >
> > ifup eth1 yields this message:
> >
> > eth1: NETDEV_TX_BUSY returned; driver should report queue full via
> > ieee_device->is_queue_full.
>
> Please use the patch here. It will be push to upstream very soon.
> http://bughost.org/bugzilla/show_bug.cgi?id=808

The offsets of the patch are off by several hundred lines,
 however the patch itself works fine. Thanks !

--alessandro

 "So much can happen by accident
  No rhyme, no reason - no one's innocent"

   (Steve Wynn - "Under The Weather")
