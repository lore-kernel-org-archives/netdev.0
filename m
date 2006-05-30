From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-rc5-mm1
Date: Tue, 30 May 2006 20:51:01 +0200
Message-ID: <6bffcb0e0605301151j7cebedc4wa376b54338d1a5ba@mail.gmail.com>
References: <20060530022925.8a67b613.akpm@osdl.org>
	 <6bffcb0e0605300859x5c8f83f5w635fd25f0100fca@mail.gmail.com>
	 <1149005329.3636.78.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:51946 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932386AbWE3SvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 14:51:02 -0400
Received: by wr-out-0506.google.com with SMTP id i21so738998wra
        for <netdev@vger.kernel.org>; Tue, 30 May 2006 11:51:01 -0700 (PDT)
To: "Arjan van de Ven" <arjan@linux.intel.com>
In-Reply-To: <1149005329.3636.78.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arjan,

On 30/05/06, Arjan van de Ven <arjan@linux.intel.com> wrote:
> On Tue, 2006-05-30 at 17:59 +0200, Michal Piotrowski wrote:
> > Hi,
> >
> > On 30/05/06, Andrew Morton <akpm@osdl.org> wrote:
> > >
> > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc5/2.6.17-rc5-mm1/
> > >
> > >
> >
> > It looks like a network stack problem.
> >
> > May 30 17:50:34 ltg01-fedora init: Switching to runlevel: 6
> > May 30 17:50:35 ltg01-fedora avahi-daemon[1878]: Got SIGTERM, quitting.
> > May 30 17:50:35 ltg01-fedora avahi-daemon[1878]: Leaving mDNS
> > multicast group on interface eth0.IPv4 with address 192.168.0.
> > 14.
> > May 30 17:50:35 ltg01-fedora kernel:
> > May 30 17:50:35 ltg01-fedora kernel: ======================================
> > May 30 17:50:35 ltg01-fedora kernel: [ BUG: bad unlock ordering detected! ]
> > May 30 17:50:35 ltg01-fedora kernel: --------------------------------------
> > May 30 17:50:35 ltg01-fedora kernel: avahi-daemon/1878 is trying to
>
> does this fix it for you?

Yes, thanks.

> Mark out of order unlocking in igmp.c as such
>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
