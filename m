From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 0/3] fix reuseaddr regression
Date: Fri, 22 Sep 2017 20:28:45 -0400
Message-ID: <20170923002844.slrxaq46zikl3zdn@destiny>
References: <1505752137-15522-1-git-send-email-jbacik@fb.com>
 <20170919.135056.44228457394918392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josef@toxicpanda.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, crobinso@redhat.com,
        labbott@redhat.com, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170919.135056.44228457394918392.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 01:50:56PM -0700, David Miller wrote:
> From: josef@toxicpanda.com
> Date: Mon, 18 Sep 2017 12:28:54 -0400
> 
> > I introduced a regression when reworking the fastreuse port stuff that allows
> > bind conflicts to occur once a reuseaddr socket successfully opens on an
> > existing tb.  The root cause is I reversed an if statement which caused us to
> > set the tb as if there were no owners on the socket if there were, which
> > obviously is not correct.
> > 
> > Dave I have follow up patches that will add a selftest for this case and I ran
> > the other reuseport related tests as well.  These need to go in pretty quickly
> > as it breaks kvm, I've marked them for stable.  Sorry for the regression,
> 
> First, please fix your "From: " field so that it actually has your full
> name rather than just your email address.  This matter when I apply
> your patches.
> 
> Second, remove the stable CC:.  For networking changes, you simply ask
> me to queue the changes up for -stable.
> 

Sorry Dave, I've fixed my git email settings and I droped the stable cc and sent
a new round.  Didn't see this until just now, my bad.

Josef
