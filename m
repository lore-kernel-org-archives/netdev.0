From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 07:40:17 -0500
Message-ID: <1108039217.22172.31.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
	 <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209103747.Y24171@build.pdx.osdl.net>
	 <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209153816.B24171@build.pdx.osdl.net>
	 <1107993369.9154.2.camel@localhost.localdomain>
	 <20050209161946.F24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <20050209161946.F24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 19:19, Chris Wright wrote:
> Then it comes back to the question of how to protect loginuid.  If it
> can be spoofed by someone with CAP_AUDIT_WRITE, then it shouldn't be
> write protected by CAP_AUDIT_CONTROL.

To be precise, isn't it true that someone with only CAP_AUDIT_WRITE
would only be able to spoof loginuids in the AUDIT_USER messages they
generate?  The loginuid on any syscall audit messages for the task would
still be the one associated with the task's audit context, so that would
not be spoofable.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
