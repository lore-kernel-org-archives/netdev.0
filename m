From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 09:12:52 -0800
Message-ID: <42235114.3070109@osdl.org>
References: <20050224155906.73890361@dxpl.pdx.osdl.net> <20050227202011.5ccefb22.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050227202011.5ccefb22.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>Someone reported a problem with skge hardware receive checksumming and PPPOE
>>> but it looks like a generic problem.  Since PPPOE adds additional header
>>> bytes the hardware computed checksum will be wrong.  
>>> 
>>> Not sure if this is correct, but shouldn't pppoe be doing the following:
> 
> 
> Changing or expanding the link level headers should only mess
> up the hw checksum if you are using CHECKSUM_HW, is that what
> your skge driver is using?

The hardware doesn't appear to actually decode the packet, it just
has the ability to compute data sum of packet starting at an arbitrary
byte offset. This matched the description of CHECKSUM_HW so
that is what I used.

The original sk98lin attempted to receive hardware checksumming
but never actually turned it on.
