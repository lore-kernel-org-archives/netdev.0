From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC][PATCH 1/3] netlink check sender
Date: Mon, 14 Feb 2005 16:22:01 -0800
Message-ID: <20050215002201.GD27645@shell0.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil> <1108386320.15437.22.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        James Morris <jmorris@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Content-Disposition: inline
In-Reply-To: <1108386320.15437.22.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Smalley (sds@tycho.nsa.gov) wrote:
> On Mon, 2005-02-14 at 07:59, Stephen Smalley wrote:
> > printk() is a leftover from debugging, I assume.  
> > Why place the check_sender() call here vs. just replacing the existing
> > security_netlink_send() call in netlink_sendmsg() with this new call?
> 
> Sorry, replacing security_netlink_send() would be bad (for SELinux
> checking), but I'm not clear on why you don't put the check_sender()
> call right after it in netlink_sendmsg() so that you ensure that you
> have complete coverage (vs. unicast-specific).

The receiver hasn't been looked up, so you don't have the
nlk_sk()->check_sender handy yet.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
