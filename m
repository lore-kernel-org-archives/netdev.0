From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:31:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915203122.GA25987@ti64.telemetry-investments.com>
References: <4148991B.9050200@pobox.com> <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 02:11:04PM -0600, David Stevens wrote:
> If the PCI bus is too slow, or MTU's too small, wouldn't
> it be better to fix those directly and use a fast host processor that can
> also do other things when not needed for networking? And why have
> memory on a NIC that can't be used by other things?
 
I tend to agree.

Referring to the Opteron with its per-CPU memory controller, Robert Olsson
just wrote in the "TX performance of Intel 82546" thread:

  This is a little breakthrough as we for the first time see some
  aggregated performance with packet forwarding and got something in
  return for all multiprocessor efforts.

  IMO this is much more important then the last percent of performance
  of pps numbers.

In 2005, we'll have commodity dual-core packages, making a four-core
(dual-CPU) system available at an attractive price point.  The number
will rise dramatically after that.  I don't really think CPU cycles are
the problem.  A  useful reason I can see for "offloading" is isolation of
concerns, e.g., locking, real-time latencies, security, etc.  But then,
why not run something like the Xen2 virtual machine environment?

Regards,

	Bill Rugolsky
