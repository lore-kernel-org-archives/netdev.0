From: Andi Kleen <ak@suse.de>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 22:53:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616205342.GH30400@wotan.suse.de>
References: <3EEE28DE.6040808@us.ibm.com> <20030616.133841.35533284.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: janiceg@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030616.133841.35533284.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2003 at 01:38:41PM -0700, David S. Miller wrote:
>    From: Janice M Girouard <janiceg@us.ibm.com>
>    Date: Mon, 16 Jun 2003 15:30:22 -0500
> 
>    EMSG_NET_LINK_UP     "%s: state change: link up, %d Mbps, %s-duplex\n"
> 
> Should indicate flow control state too.

It would be actually useful  to wrap these in real functions.

Why? It will make supporting netconsole easier which has to be careful
to never recurse in the network driver.

-Andi
