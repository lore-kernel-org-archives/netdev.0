From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(12/20): reorder code to avoid prototype function declarations
Date: Mon, 28 Mar 2005 16:55:03 -0700
Message-ID: <20050328235503.GL29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch reorders functions to avoid the need for function
prototypes. In practice, low-level routines are moved to the top of
the file and driver API functions to the bottom. This is how most
Linux drivers are laid out.

There are no functional changes here.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>




[I have omitted the patch because it's twice the size of the original
file, drivers/net/mv643xx_eth.c, and not useful for analyzing changes
since so many functions were moved.  Again, the code is unchanged
other than changing the order of the functions in the source file.]
