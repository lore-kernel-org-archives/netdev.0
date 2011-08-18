From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] PM: add macro to test for runtime PM events
Date: Thu, 18 Aug 2011 16:26:56 -0700
Message-ID: <20110818232656.GA29608@kroah.com>
References: <Pine.LNX.4.44L0.1108181600020.1628-100000@iolanthe.rowland.org>
 <201108182252.10364.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Linux-pm mailing list <linux-pm@lists.linux-foundation.org>,
	USB list <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-input@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-input-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201108182252.10364.rjw@sisk.pl>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 18, 2011 at 10:52:10PM +0200, Rafael J. Wysocki wrote:
> Hi,
> 
> On Thursday, August 18, 2011, Alan Stern wrote:
> > This patch (as1482) adds a macro for testing whether or not a
> > pm_message value represents an autosuspend or autoresume (i.e., a
> > runtime PM) event.  Encapsulating this notion seems preferable to
> > open-coding the test all over the place.
> > 
> > Signed-off-by: Alan Stern <stern@rowland.harvard.edu>
> > 
> > ---
> > 
> > This is a minor change in the PM API, but most of the affected files 
> > are in the USB subsystem.  Therefore either Rafael or Greg might prefer 
> > to accept this patch.
> 
> I can take the patch if Greg is fine with that.

Fine with me:
	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

