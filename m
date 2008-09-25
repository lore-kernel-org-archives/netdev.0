From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] net: remove LLTX in atl2 driver
Date: Thu, 25 Sep 2008 18:58:49 -0500
Message-ID: <20080925185849.0df482e2@osprey.hogchain.net>
References: <1222302922-13200-1-git-send-email-kexin.hao@windriver.com>
	<48DBF4DD.8060908@redhat.com>
	<48DBFAB5.2010709@garzik.org>
	<48DC11F5.20900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Kevin Hao <kexin.hao@windriver.com>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754371AbYIYX7P@vger.kernel.org>
In-Reply-To: <48DC11F5.20900@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Sep 2008 18:34:29 -0400
Chris Snook <csnook@redhat.com> wrote:

> 
> I'm all in favor of removing legacy cruft.  I want to know a little
> more about it so we can remove it from the atl1 code as well.
> Ultimately most of this will be shared code.

Yes, LLTX can (and should) be removed from the atl1 code.  I had an
exchange with Herbert Xu and David Miller on LKML a few weeks ago, and
they gave me a few tips on how to do it, but I haven't yet had the
time.  What takes an experienced netdev warrior about a half hour to
implement unfortunately takes me days of after-dayjob time as I track
through all the calls that that are affected and test the modified
driver.

Now back to atl2...  I'd like to hear from Kevin also whether he tested
the LLTX removal.  I'm building the driver with his patch as we speak,
and I'll test it myself this weekend, but Kevin I'd still like to know
if you tested the patch.

Thanks,
Jay
