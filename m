From: Olaf Hering <olh@suse.de>
Subject: Re: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 21:12:24 +0200
Message-ID: <20060721191224.GA7685@suse.de>
References: <20060721185945.GA7611@suse.de> <200607212103.23954.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jason Lunz <lunz@falooley.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:17064 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751108AbWGUTMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 15:12:25 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200607212103.23954.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 On Fri, Jul 21, Michael Buesch wrote:

> On Friday 21 July 2006 20:59, Olaf Hering wrote:
> > 
> > bcm43xx_get_drvinfo in 2.6.18-rc2 unfortunately uses UTS_RELEASE as
> > driver version. I think this specific info can be obtained by other
> > ways.
> > Can you give bcm43xx a real version number and provide it via the
> > ethtool ioctl?
> 
> I am not going to maintain a bogus version number.
> What about simply returning 1.0 and be done with it.
> I don't think it matters. 1.0 is as bogus as any other value.

I'm less concerned about the actual number, just UTS_RELEASE should
disappear, and the #include.
