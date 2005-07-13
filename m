From: Greg KH <greg@kroah.com>
Subject: Re: [stable] Re: [05/11] SMP fix for 6pack driver
Date: Wed, 13 Jul 2005 15:13:11 -0700
Message-ID: <20050713221311.GA30039@kroah.com>
References: <20050713184130.GA9330@kroah.com> <20050713184331.GG9330@kroah.com> <20050713220123.GA3292@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, torvalds@osdl.org, akpm@osdl.org,
        "Theodore Ts'o" <tytso@mit.edu>,
        Zwane Mwaikambo <zwane@arm.linux.org.uk>, netdev@vger.kernel.org,
        Justin Forbes <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org,
        ralf@linux-mips.org, "Randy.Dunlap" <rdunlap@xenotime.net>,
        Chuck Wolber <chuckw@quantumlinux.com>, jgarzik@pobox.com,
        stable@kernel.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262800AbVGMWSt@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050713220123.GA3292@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14, 2005 at 12:01:23AM +0200, Francois Romieu wrote:
> Greg KH <gregkh@suse.de> :
> > -stable review patch.  If anyone has any objections, please let us know.
> > 
> > ------------------
> > 
> > 
> > Drivers really only work well in SMP if they actually can be selected.
> > This is a leftover from the time when the 6pack drive only used to be
> > a bitrotten variant of the slip driver.
> 
> Is the guideline above from 28/04/2005 obsoleted ?
> 
>  - It must fix a problem that causes a build error (but not for things
>    marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
>    security issue, or some "oh, that's not good" issue.  In short,
>    something critical.

It lets the driver be built, when it previously could not be, unless the
user used a config option that almost no one does...

That's pretty critical if you ask me.

thanks,

greg k-h
