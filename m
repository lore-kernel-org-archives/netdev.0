From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Mon, 15 Dec 2003 17:32:41 -0800
Sender: linux-security-module-bounces@wirex.com
Message-ID: <20031215173241.B14552@osdlab.pdx.osdl.net>
References: <20031212161617.C24246@osdlab.pdx.osdl.net>
	<Xine.LNX.4.44.0312122219530.4813-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
	linux-security-module@wirex.com,
	Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0312122219530.4813-100000@thoron.boston.redhat.com>;
	from jmorris@redhat.com on Fri, Dec 12, 2003 at 10:44:24PM -0500
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> I'm not sure how this would be a namespace issue -- do you mean a data 
> format issue?

I just mean, applications are coded for specific security module.

> Yep, allowing the security module to update the returned length is now
> implemented.
> 
> > Perhaps buffer is too small, can len be vector for that info?
> 
> I would not advise updating len on error -- it's a bad idea in general to
> interpret any returned data from failed syscalls except the error number.

Right, in some cases a NULL buffer or 0 buflen is a probe for size.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
