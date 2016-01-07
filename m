From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net-thunder: One check less in
 nicvf_register_interrupts() after error detection
Date: Thu, 07 Jan 2016 11:44:06 -0800
Message-ID: <1452195846.4028.24.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	 <5685A273.6070607@users.sourceforge.net>
	 <20160107110701.GE25086@rric.localdomain>
	 <568EBCE7.4060502@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <568EBCE7.4060502@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-07 at 20:30 +0100, SF Markus Elfring wrote:
> > > Adjust a jump target to eliminate a check before error logging.
> > > Use the identifier "report_failure" instead of "err".
> > I don't see much value in those changes
> Thanks for your feedback.
> > Using the 'err' label is ok as it is not misleading and common use.
> Is such a short jump label enough explanation for the information
> "what" and "why"?

When there is only one type of error possible, yes.

> > And, there is no need to optimize the check since this is not the
> > fast path
> Really? - Is it a bit more efficient to avoid a double check for the
> variable "ret" at the end of the current implementation for the
> discussed function?

Before asking questions you could answer yourself,
please look at object code produced by the compiler
before and after your proposed changes.
