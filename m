From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 18:56:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056581805.27267.14.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	 <1056547262.1945.1436.camel@brick.watson.ibm.com>
	 <1056548544.1944.1488.camel@brick.watson.ibm.com>
	 <20030625114243.F84526@shell.cyberus.ca>
	 <1056562079.1944.1961.camel@brick.watson.ibm.com>
	 <16122.8066.928895.202985@nanango.paulus.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, Rusty Russell <rusty@rustcorp.com.au>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul MacKerras <paulus@samba.org>
In-Reply-To: <16122.8066.928895.202985@nanango.paulus.ozlabs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-06-25 at 18:17, Paul Mackerras wrote:
> James might be able to comment better than me on what will happen if
> packets get reordered during the negotiation phase of a PPP
> connection.  I think the worst is that some packets will have to be
> retransmitted and thus the negotiation will take several seconds
> longer than it needs to.

This is exactly what we're dealing with the current "bug"; the worst
case effect is a delay.  I don't think heroic measures are called for
the sake of this PPPoE issue alone.

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
