From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 19:49:29 +0300
Message-ID: <20050209164929.GA30007@yakov.inr.ac.ru>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <Pine.LNX.4.62.0502080658310.32526@kaber.coreworks.de> <1107956079.17568.42.camel@moss-spartans.epoch.ncsc.mil> <20050209141945.GA28864@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds@epoch.ncsc.mil>,
        Linux Audit Discussion <linux-audit@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>, netdev@oss.sgi.com,
        davem@davemloft.net
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050209141945.GA28864@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> if (down_trylock(&audit_netlink_sem))
> 	return;
> 
> with plain down(&audit_netlink_sem);

I am sorry, this is wrong. Dequeue may happen in another process context
in any case.

Alexey
