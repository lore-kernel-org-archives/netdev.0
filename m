From: Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [2/2] 2.6.22-rc4: known regressions with patches v3
Date: Wed, 13 Jun 2007 21:58:05 +0200
Message-ID: <46704C4D.5010803@googlemail.com>
References: <46704B5D.5020106@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>,
	Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Paulo Pereira <pfmp.404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46704B5D.5020106-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc4
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Networking

Subject    : no irda0 interface (2.6.21 was OK), smsc does not find chip
References : http://lkml.org/lkml/2007/6/3/16
Submitter  : Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Handled-By : Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
             Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/6/7/237
Status     : patch was suggested



SELinux

Subject    : very high non-preempt latency in context_struct_compute_av()
References : http://lkml.org/lkml/2007/6/4/78
Submitter  : Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Handled-By : Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
             James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/6/7/334
Status     : patch available



USB

Subject    : list_add corruption. prev->next should be next (f7d28794), but was f0df8ed4 (prev=f0df8ed4) Kernel Bug at lib/list_debug.c:33
References : http://bugzilla.kernel.org/show_bug.cgi?id=8561
Submitter  : Paulo Pereira <pfmp.404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Handled-By : Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=8561#c8
Status     : patch was suggested



Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
