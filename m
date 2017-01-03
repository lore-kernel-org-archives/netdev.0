From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Tue, 03 Jan 2017 22:19:29 +0100
Message-ID: <3286019.I2UkVCJq41@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de> <1456945629-1793533-2-git-send-email-arnd@arndb.de> <20170103152436.GA26156@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        devel@driverdev.osuosl.org, Karsten Keil <isdn@linux-pingi.de>,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170103152436.GA26156@kroah.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, January 3, 2017 4:24:36 PM CET Greg Kroah-Hartman wrote:
> On Wed, Mar 02, 2016 at 08:06:46PM +0100, Arnd Bergmann wrote:
> > The icn, act2000 and pcbit drivers are all for very old hardware,
> > and it is highly unlikely that anyone is actually still using them
> > on modern kernels, if at all.
> > 
> > All three drivers apparently are for hardware that predates PCI
> > being the common connector, as they are ISA-only and active
> > PCI ISDN cards were widely available in the 1990s.
> > 
> > Looking through the git logs, it I cannot find any indication of a
> > patch to any of these drivers that has been tested on real hardware,
> > only cleanups or global API changes.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Acked-by: Karsten Keil <isdn@linux-pingi.de>
> 
> This patch got added in the 4.6 kernel release.  As I am now taking
> patches for 4.11-rc1, I figure it is time to just delete the
> drivers/staging/i4l/ directory now, given that no one has really done
> anything with it.  If people show up that wish to maintain it, I'll be
> glad to revert it, or if someone really screams in the next week.
> Otherwise it's time to just move on 

Sounds good to me. My original series contained four more patches that
I did not post again after there was some concern[1] that we did not
come to a conclusion on:

isdn: gigaset: remove i4l code
isdn: move isdnhdlc out of i4l
isdn: i4l: move hisax driver to staging
isdn: move i4l to staging

I can post those as well, at least I think the first two are helpful
for untangling i4l from the rest of ISDN.  I also still think that
moving hisax and i4l to staging is reasonable given the state of
that code, even if there are a couple of users today.

	Arnd

[1] https://lkml.org/lkml/2016/3/4/762
