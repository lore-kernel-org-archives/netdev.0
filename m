From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.4 sunrpc oops.
Date: Mon, 15 Mar 2004 15:38:53 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315203853.GF3114@fieldses.org>
References: <20040315194642.GB19555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040315194642.GB19555@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 15, 2004 at 07:46:42PM +0000, Dave Jones wrote:
> modprobe auth_rpcgss
> rmmod auth_rpcgss
> rmmod sunrpc
> *bang*
> 
> Seems to survive rmmod sunrpc usually, so it's the auth_rpcgcc
> module leaving something around long after its dead perhaps?

Yes, this is my fault, apologies.  I'll follow up with a patch as soon
as I've made one....--Bruce Fields
