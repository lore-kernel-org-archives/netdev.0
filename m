From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 11:16:00 +0300
Message-ID: <20090130081600.GA2717@ioremap.net>
References: <20090128212114.38be3e8c@extreme> <20090129103544.GC22110@redhat.com> <20090129213549.7fadfa2e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
	Fedora/Linux Management Tools <et-mgmt-tools@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:58315 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbZA3IQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 03:16:10 -0500
Content-Disposition: inline
In-Reply-To: <20090129213549.7fadfa2e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Jan 29, 2009 at 09:35:49PM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> > > This is probably related to the new GEM code. But on 2.6.29-rc2 if I start up the virtual
> > > machine manager then run a guest, the display gets screwed up.
> > > 
> > > virt-machine-manager
> > >   click local-host (System)
> > >   Run one of the existing VM's
> > >  
> > > The virtual console window then cause a dialog about allowing remote access to display;
> > > (this never happened with earlier kernels), regression #1
> > > 
> > > Then if I allow it multiple copies of the window start cloning and general chaos ensues.
> > 
> > You'll have to provide more useful information than 'screwed up' and
> > 'general choas' if we're to properly dianose this. A screenshot of what
> > is wrong if there's a graphics rendering problem would be a start.
> > 
> > Also, what GTK-VNC version do you have ?  Make sure it is at least
> > 0.3.8, so that it is using Cairo for rendering, and not old buggy
> > OpenGL based GtkGLExt.
> > 
> > Daniel
> 
> The problem is only in the net-next tree (not mainline 2.6.29-rcX).
> Bisected down to this commit is the problem:
> 
> a9d8f9110d7e953c2f2b521087a4179677843c2a is first bad commit
> commit a9d8f9110d7e953c2f2b521087a4179677843c2a
> Author: Evgeniy Polyakov <zbr@ioremap.net>
> Date:   Mon Jan 19 16:46:02 2009 -0800

Any chance to get a bit more information about what this console does?
Like how it binds or get a strace?
Will you be able to run a debug patch which will dump lots of info into
the dmesg and slow things down a bit?

-- 
	Evgeniy Polyakov
