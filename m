From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 09:14:27 -0800
Message-ID: <20050210091427.K24171@build.pdx.osdl.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <1107958621.19262.524.camel@hades.cambridge.redhat.com> <1107960659.4837.9.camel@serge> <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil> <20050209103747.Y24171@build.pdx.osdl.net> <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil> <20050209153816.B24171@build.pdx.osdl.net> <1107993369.9154.2.camel@localhost.localdomain> <20050209161946.F24171@build.pdx.osdl.net> <1108039217.22172.31.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Audit Discussion <linux-audit@redhat.com>, netdev@oss.sgi.com,
        David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru
To: Stephen Smalley <sds@epoch.ncsc.mil>
Content-Disposition: inline
In-Reply-To: <1108039217.22172.31.camel@moss-spartans.epoch.ncsc.mil>; from sds@epoch.ncsc.mil on Thu, Feb 10, 2005 at 07:40:17AM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Smalley (sds@epoch.ncsc.mil) wrote:
> On Wed, 2005-02-09 at 19:19, Chris Wright wrote:
> > Then it comes back to the question of how to protect loginuid.  If it
> > can be spoofed by someone with CAP_AUDIT_WRITE, then it shouldn't be
> > write protected by CAP_AUDIT_CONTROL.
> 
> To be precise, isn't it true that someone with only CAP_AUDIT_WRITE
> would only be able to spoof loginuids in the AUDIT_USER messages they
> generate?  The loginuid on any syscall audit messages for the task would
> still be the one associated with the task's audit context, so that would
> not be spoofable.

Yes, that's true.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
