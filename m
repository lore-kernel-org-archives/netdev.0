From: Andy Walls <awalls@md.metrocast.net>
Subject: Re: [PATCH] IPv4: Remove check for ipv4_is_lbcast() that will
 always return false
Date: Sun, 17 Oct 2010 20:25:51 -0400
Message-ID: <1287361551.2320.17.camel@morgan.silverblock.net>
References: <1286727021.2435.17.camel@localhost>
	 <20101012.122841.183039561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101012.122841.183039561.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-10-12 at 12:28 -0700, David Miller wrote:
> From: Andy Walls <awalls@md.metrocast.net>
> Date: Sun, 10 Oct 2010 12:10:21 -0400
> 
> > In making an IPv4 routing decision, packets with an all 1's broadcast
> > destination are accepted as input packets, before being checked for being a
> > martian.  Remove the martian check for the all 1's broadcast destination
> > address.  Make the initial check for the all 1's broadcast destination
> > address easier to read.
> > 
> > Signed-off-by: Andy Walls <awalls@md.metrocast.net>
> 
> Your email client corrupted this patch, by turning tab characters
> into spaces, amongst other things.


No, that was me in a rush, thoughtlessly cutting and pasting into the
e-mail client window.

I will resubmit shortly.  Sorry for the wasting your time on the
malformed submission.

Regards,
Andy

> Please give Documentation/email-clients.txt a read and resubmit this
> patch after you have these issues sorted out.
> 
> Thank you.
