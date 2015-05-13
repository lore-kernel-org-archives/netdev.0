From: Greg KH <greg@kroah.com>
Subject: Re: [oss-security] [PATCH 0/4] ozwpan: Four remote packet-of-death
 vulnerabilities
Date: Wed, 13 May 2015 11:53:22 -0700
Message-ID: <20150513185322.GA4029@kroah.com>
References: <1431542014-3239-1-git-send-email-Jason@zx2c4.com>
 <20150513184331.GA1847@kroah.com>
 <CAHmME9pL6kU5D9YNZdDMHXc0harTZ_oDo9xEpmojEN9_qs+qpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oss-security <oss-security@lists.openwall.com>,
	shigekatsu.tateno@atmel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHmME9pL6kU5D9YNZdDMHXc0harTZ_oDo9xEpmojEN9_qs+qpQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 13, 2015 at 08:48:31PM +0200, Jason A. Donenfeld wrote:
> On Wed, May 13, 2015 at 8:43 PM, Greg KH <greg@kroah.com> wrote:
> > Any reason you didn't cc: the maintainer who could actually apply these
> > to the kernel tree?
> 
> I did, look at the email again: the first recipient is
> <shigekatsu.tateno@atmel.com>.
> 
> >From the MAINTAINERS file:
>     STAGING - OZMO DEVICES USB OVER WIFI DRIVER
>     M:      Shigekatsu Tateno <shigekatsu.tateno@atmel.com>
>     S:      Maintained
>     F:      drivers/staging/ozwpan/

$ ./scripts/get_maintainer.pl --file drivers/staging/ozwpan/Makefile 
Shigekatsu Tateno <shigekatsu.tateno@atmel.com> (maintainer:STAGING - OZMO DE...)
Greg Kroah-Hartman <gregkh@linuxfoundation.org> (supporter:STAGING SUBSYSTEM)
devel@driverdev.osuosl.org (open list:STAGING SUBSYSTEM)
linux-kernel@vger.kernel.org (open list)

You missed me, and the driverdev mailing list.  netdev could care less
about this.

Please resend to get the proper people involved.

thanks,

greg k-h
