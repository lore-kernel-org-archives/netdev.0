From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 09:20:12 +0000
Message-ID: <1108027212.7716.146.camel@baythorne.infradead.org>
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
Cc: Linux Audit Discussion <linux-audit@redhat.com>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050209161946.F24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 16:19 -0800, Chris Wright wrote:
> Then it comes back to the question of how to protect loginuid.  If it
> can be spoofed by someone with CAP_AUDIT_WRITE, then it shouldn't be
> write protected by CAP_AUDIT_CONTROL.

I'm not sure I agree with that. With CAP_AUDIT_WRITE you _can't_ modify
the loginuid of the audit logs of your own actions. You can only modify
the loginuid on the messages you pull out of thin air and send. You can
already make up the rest of the payload -- why shouldn't you be allowed
to make up the loginuid too? You could be reporting something that
someone _else_ has done, after all.

Or am I misunderstanding the intended use of CAP_AUDIT_WRITE?

-- 
dwmw2
