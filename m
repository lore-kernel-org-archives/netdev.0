From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 07:51:23 -0500
Message-ID: <1108039883.22172.40.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
	 <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209103747.Y24171@build.pdx.osdl.net>
	 <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209153816.B24171@build.pdx.osdl.net>
	 <20050209171115.G24171@build.pdx.osdl.net>
	 <1108038968.22172.26.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Linux Audit Discussion <linux-audit@redhat.com>,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <1108038968.22172.26.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-02-10 at 07:36, Stephen Smalley wrote:
> Why not just call the security handler from the security_netlink_send()
> function, which is already called by netlink_sendmsg()?

Ok, I can see why you wouldn't want to do that, but why not just call
the handler immediately after security_netlink_send() then in
netlink_sendmsg()?  What is the advantage of deferring to
netlink_sendskb (and some other location for broadcasts)?

-- 
Stephen Smalley <sds@tycho.nsa.gov>
National Security Agency
