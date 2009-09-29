From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 21:08:25 +0400
Message-ID: <20090929170824.GB32330@ioremap.net>
References: <200909251123.03482.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru> <20090929132415.GB4538@redhat.com> <200909291547.21528.borntraeger@de.ibm.com> <20090929140718.GA23858@ioremap.net> <20090929142538.GA10180@redhat.com> <20090929145413.GA26327@ioremap.net> <20090929153631.GA12699@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753289AbZI2RIX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090929153631.GA12699@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2009 at 05:36:31PM +0200, Oleg Nesterov (oleg@redhat.com) wrote:
> > Doesn't it only check pgid while patch intention was to send
> > notification about sid?
> 
> If the proposed sid already was the session id, then prgp shouldn't
> be empty.
> 
> but this doesn't really matter, we also check ->signal->leader
> (not sure, but afaics this check is not strictly necessary because
>  of PIDTYPE_PGID check)

Ok, I see, thanks.

-- 
	Evgeniy Polyakov
