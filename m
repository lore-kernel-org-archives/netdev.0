From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 16:19:46 -0800
Message-ID: <20050209161946.F24171@build.pdx.osdl.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <1107958621.19262.524.camel@hades.cambridge.redhat.com> <1107960659.4837.9.camel@serge> <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil> <20050209103747.Y24171@build.pdx.osdl.net> <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil> <20050209153816.B24171@build.pdx.osdl.net> <1107993369.9154.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Audit Discussion <linux-audit@redhat.com>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: David Woodhouse <dwmw2@infradead.org>
Content-Disposition: inline
In-Reply-To: <1107993369.9154.2.camel@localhost.localdomain>; from dwmw2@infradead.org on Wed, Feb 09, 2005 at 11:56:09PM +0000
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David Woodhouse (dwmw2@infradead.org) wrote:
> On Wed, 2005-02-09 at 15:38 -0800, Chris Wright wrote:
> >I just don't see it making sense to add another credential for a special
> >case.  The signal code already peaks into the siginfo struct when queueing
> >a signal to make sure some user isn't trying to send si_code == SI_KERNEL
> >or similar.  Perhaps audit could do that with it's own payload during send.
> >No matter how we slice it, it's a special case.
> 
> I'm not entirely sure the check is needed anyway. This is a trusted
> application sending audit messages. Why shouldn't it be permitted to log
> auditable events which were triggered by someone _else_? 

Then it comes back to the question of how to protect loginuid.  If it
can be spoofed by someone with CAP_AUDIT_WRITE, then it shouldn't be
write protected by CAP_AUDIT_CONTROL.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
