From: "David S. Miller" <davem@davemloft.net>
Subject: Re: pppoe and receive checksum offload
Date: Sun, 27 Feb 2005 20:20:11 -0800
Message-ID: <20050227202011.5ccefb22.davem@davemloft.net>
References: <20050224155906.73890361@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050224155906.73890361@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Feb 2005 15:59:06 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Someone reported a problem with skge hardware receive checksumming and PPPOE
> but it looks like a generic problem.  Since PPPOE adds additional header
> bytes the hardware computed checksum will be wrong.  
> 
> Not sure if this is correct, but shouldn't pppoe be doing the following:

Changing or expanding the link level headers should only mess
up the hw checksum if you are using CHECKSUM_HW, is that what
your skge driver is using?
