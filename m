From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] Checkpatch: coding style errors in Nvidia ethernet
 driver
Date: Fri, 10 Oct 2014 10:04:59 -0700
Message-ID: <1412960699.8770.33.camel@joe-AO725>
References: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
	 <1412953387.8770.23.camel@joe-AO725>
	 <20141010164515.GA3596@linux.akshay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Akshay Sarode <akshaysarode21@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0033.hostedemail.com ([216.40.44.33]:49044 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751779AbaJJRFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:05:03 -0400
In-Reply-To: <20141010164515.GA3596@linux.akshay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 22:15 +0530, Akshay Sarode wrote:
> On Fri, Oct 10, 2014 at 08:03:07AM -0700, Joe Perches wrote:
> > On Fri, 2014-10-10 at 13:31 +0530, Akshay Sarode wrote:
> > > ERROR: "foo* bar" should be "foo *bar"
> > > ERROR: do not initialise statics to 0 or NULL
> > > CHECK: spinlock_t definition without comment
> > > Signed-off-by: Akshay Sarode <akshaysarode21@gmail.com>
> > []
> > > diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> > []
> > > @@ -911,12 +913,18 @@ enum {
> > []
> > >  /*
> > >   * Debug output control for tx_timeout
> > >   */
> > > -static bool debug_tx_timeout = false;
> > > +enum {
> > > +	NV_DEBUG_TX_TIMEOUT_DISABLED,
> > > +	NV_DEBUG_TX_TIMEOUT_ENABLED
> > > +};
> > > +
> > > +static bool debug_tx_timeout = NV_DEBUG_TX_TIMEOUT_DISABLED;
> > 
> > Adding this enum is not useful.
> > 
> Sorry, If I may have not checked the code properly. I am a newbie here and I was hoping to start with checking coding styles.

No worries, welcome.

Starting with fixing a coding style defect or three is
just fine to learn how to compile and test the kernel.

But generally it's more useful to find things that make
the code better, more readable, smaller, faster, etc.

Also if you have some functional defect or enhancement
to implement, that's even better still.

> I'll check again.

Using an enum for a bool isn't very sensible.
true/false exist already.

>  Also there are a whole lot of warnings for line over 80 characters.

I wouldn't bother with long line conversions unless
you're doing something else at the same time.

If you want to do them for the practice, please do
them on files in drivers/staging/.
