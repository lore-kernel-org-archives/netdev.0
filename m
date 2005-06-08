From: Dave Jones <davej@redhat.com>
Subject: Re: ipw2100: firmware problem
Date: Wed, 8 Jun 2005 15:49:02 -0400
Message-ID: <20050608194902.GK876@redhat.com>
References: <20050608142310.GA2339@elf.ucw.cz> <200506081744.20687.vda@ilport.com.ua> <42A7268D.9020402@linux.intel.com> <20050608.124332.85408883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jketreno@linux.intel.com, vda@ilport.com.ua, pavel@ucw.cz,
        jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050608.124332.85408883.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 12:43:32PM -0700, David S. Miller wrote:
 
 > I am likely to always take the position that device firmware
 > belongs in the kernel proper, not via these userland and filesystem
 > loading mechanism, none of which may be even _available_ when
 > we first need to get the device going.

FWIW, I agree, though the licensing of the Intel firmware
prevents that iirc.  The biggest problem I face with this driver
in Fedora kernels is users mismatching firmware rev with the
driver version. Another problem that disappears if the two
are shipped together.

Of course this would then bring out the armchair lawyers on
the list and cause another 500 emails debating whether it
violates the gpl.

		Dave
