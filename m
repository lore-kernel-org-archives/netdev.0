From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [RFC][PATCH 1/3] netlink check sender
Date: Mon, 14 Feb 2005 08:05:20 -0500
Message-ID: <1108386320.15437.22.camel@moss-spartans.epoch.ncsc.mil>
References: <20050212010109.V24171@build.pdx.osdl.net>
	 <20050212010243.W24171@build.pdx.osdl.net>
	 <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, James Morris <jmorris@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-14 at 07:59, Stephen Smalley wrote:
> printk() is a leftover from debugging, I assume.  
> Why place the check_sender() call here vs. just replacing the existing
> security_netlink_send() call in netlink_sendmsg() with this new call?

Sorry, replacing security_netlink_send() would be bad (for SELinux
checking), but I'm not clear on why you don't put the check_sender()
call right after it in netlink_sendmsg() so that you ensure that you
have complete coverage (vs. unicast-specific).

-- 
Stephen Smalley <sds@tycho.nsa.gov>
National Security Agency
