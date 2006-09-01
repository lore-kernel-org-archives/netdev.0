From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Fri, 1 Sep 2006 09:35:58 -0700
Message-ID: <20060901163558.GB13815@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831171258.GD11836@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:62969 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1750724AbWIAQjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 12:39:13 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1157093640.2878.26.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 08:54:00AM +0200, Johannes Berg wrote:
> On Thu, 2006-08-31 at 10:12 -0700, Jean Tourrilhes wrote:
> 
> > 	And I strongly disagree with your disagrement ;-)
> 
> You're of course free to do that :) But let me explain.

	And my explanation is even more simple : let's not throw the
baby with the bathwater. If things are broken in WE, let's just fix
it. I've always worked with people working with me.
	Note that one thing that worry me with your approach is
footprint. I've used various embedded devices over the years, such as
the Gumstix (4MB Flash), and this is why WE was optimised for
footprint.

> > 	I'm sorry to say it like this, but I hope my work will not be
> > impacted by vaporware. How many drivers are currently converted to
> > nl80211 ?
> 
> None, I have to admit, of course. But I hope you realise that I can
> impossibly convert all drivers at once and all by myself. I merely set
> out a framework in which it is easy to add new features, new calls and
> make things behave.

	I hope you realised that you can't expect driver authors to
convert their driver, it won't happen. I've implemented WE in half the
driver in the kernel myself, and I convert WE in those drivers myself.

> > 	The reason why those new features are good for you :
> > 		o They give you a template on how you could implement
> > those features in nl80211, saving you design time.
> 
> Gack. I'm inclined to not even respond to this, but I am convinced that
> having all the unions and ill-defined semantics with one field having
> multiple meanings is in no way saving me design time because it's part
> of the problem I intend to completely avoid.

	Can we have specifics, instead of generalities ? Every time
somebody pointed out a specific thing that was broken in WE, I've
fixed it (with a few exceptions).
	Case in point : the ESSID change (which was a pain to
coordinate in user space).

> Actually, no. But that's beside the point anyway. Actually, I think that
> publishing WE over netlink was a mistake.

	I don't understand, in the last few years everybody was
clamoring for a Netlink interface, and now that it is done, people say
it is a stupid thing. Any specifics ?

> The real
> problem with WE is, as I previously said, the ill-defined semantics of
> both the user-space API and the in-kernel API.

	I don't understand why you say it's ill defined, it 100%
documented in the iwconfig man page.

> Setting an ESSID to all-zeroes to disable something (or
> was it all-ones to disable??)

	This has *never* existed, there has always been a separate
flag to indicate that since the beggining. I don't know where you got
that.
	Any other misconception I need to straighten ?

> johannes

	Regards,

	Jean
