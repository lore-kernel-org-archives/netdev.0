From: "David S. Miller" <davem@rth.ninka.net>
Subject: Re: O_DIRECT sockets? (was [RESEND] tuning linux for high network
	performance?)
Date: 24 Oct 2002 03:46:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035456413.10558.5.camel@rth.ninka.net>
References: <200210231218.18733.roy@karlsbakk.net>
	<200210231726.21135.roy@karlsbakk.net> <3DB6CF9E.327E165F@us.ibm.com>
	<200210241214.59812.roy@karlsbakk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>, bert hubert <ahu@ds9a.nl>,
   netdev@oss.sgi.com, Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
In-Reply-To: <200210241214.59812.roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2002-10-24 at 03:14, Roy Sigurd Karlsbakk wrote:
> I can't use sendfile(). I'm working with files > 4GB, and from man 2 sendfile:

That's what sendfile64() is for.  In fact every vendor I am aware
of is shipping the sys_sendfile64() patch in their kernels and
an appropriately fixed up glibc.
