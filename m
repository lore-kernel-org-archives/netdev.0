From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 10:52:17 -0800
Message-ID: <20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
References: <1106932637.3778.92.camel@localhost.localdomain>
	<20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	<1106937110.3864.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.co,
        "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lorenzo =?ISO-8859-1?B?SGVybuFuZGV6IEdhcmPtYS1IaWVycm8=?=
 <lorenzo@gnu.org>
In-Reply-To: <1106937110.3864.5.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 19:31:50 +0100
L
> > Okay, but:
> > * Need to give better explanation of why this is required, 
> >   existing randomization code in network is compromise between
> >   performance and security. So you need to quantify the performance
> >   impact of this, and the security threat reduction.
> 
> Performance impact is none AFAIK.
> I've explained them in an early reply to Adrian [1].

When I did the port randomization patch the benchmark that was most impacted
was LMBENCH.  The biggest change was in the communications latency results.

If you want, you can sign up for a free access to OSDL test machines
and use STP to run lmbench and easily get before/after results.

1. Go to osdl.org and get associate account http://osdl.org/join_form

2. Submit patch to Patch Lifecycle Manager http://osdl.org/plm-cgi/plm

3. Choose test to run Scalable Test Platform (STP) 
http://osdl.org/lab_activities/kernel_testing/stp/


-- 
Stephen Hemminger	<shemminger@osdl.org>
