From: Jeff Garzik <jgarzik@redhat.com>
Subject: Re: acenic lockup
Date: Thu, 8 May 2003 13:11:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508131135.G22565@devserv.devel.redhat.com>
References: <20030507.123421.133894691.davem@redhat.com> <200305072221.CAA00973@mops.inr.ac.ru> <20030508.090049.48375778.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, anton@samba.org, jes@trained-monkey.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030508.090049.48375778.davem@redhat.com>; from davem@redhat.com on Thu, May 08, 2003 at 09:00:49AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 08, 2003 at 09:00:49AM -0700, David S. Miller wrote:
> Note to Jeff, independant of what is being discussed here, a real
> audit of drivers that blindly invoke netif_wake_queue() from transmit
> timeout watchdog routine is in order at some point.  This is what
> Alexey is referring to as "same bogus netif_wake_queue()".

Agreed.  Alexey has pointed out netif_wake_queue stupidities in
drivers before, and he's absolutely right.

	Jeff



P.S. Can you please email @pobox.com for stuff that is not Red Hat
specific?  I am trying to use @redhat.com for only official Red Hat
business.  My boss forces me to bk-commit as @redhat.com, otherwise you
would never see that address in public at all.
