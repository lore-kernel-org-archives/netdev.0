From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] add iocb to network protocols
Date: Thu, 10 Oct 2002 16:36:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010.163646.35014672.davem@redhat.com>
References: <20021010183528.A13432@redhat.com>
	<20021010.162240.102769920.davem@redhat.com>
	<20021010194025.B13432@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com
In-Reply-To: <20021010194025.B13432@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Benjamin LaHaise <bcrl@redhat.com>
   Date: Thu, 10 Oct 2002 19:40:25 -0400

   On Thu, Oct 10, 2002 at 04:22:40PM -0700, David S. Miller wrote:
   > 
   > +#include <net/scm.h>	/* for sock_iocb */
   > 
   > What is this?
   
   The private area of an iocb for network operations contains a struct 
   scm_cookie.

I know this.  But the comment is wrong, when you say "for FOO"
next to an include that means "I'm including this to get the
definition of FOO".

Just delete the comment entirely, it really isn't needed.

Otherwise looks ok at first glance.
