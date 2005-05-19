From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 08:13:40 -0700
Message-ID: <428CAD24.904@us.ibm.com>
References: <20050518235329.GA17946@us.ibm.com>	<428BD7E7.5080207@us.ibm.com> <20050518.220031.75189050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050518.220031.75189050.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>>I think this is a good thing to have, gives us performance
>>gain (equivalent to using/not using checksum offload) and
>>has very little impact on the bridging layer, and is
>>independent of the virtualization stuff..
> 
> 
> I agree but keep in mind that when bridging over non-checksumming
> devices it will be more expensive.  Especially for TCP.

Yep - as I just said to Herbert - perhaps worthwhile then
conditional upon support of checksum offload & SG?

thanks,
Nivedita
