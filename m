From: Steve Hill <steve@services.navaho.net>
Subject: Re: More IPSEC trouble
Date: Thu, 10 Mar 2005 16:32:01 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0503101631310.18067@sorbus2.navaho>
References: <Pine.LNX.4.61.0503101229380.18067@sorbus2.navaho>
 <42306145.3050603@6wind.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
To: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
In-Reply-To: <42306145.3050603@6wind.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005, Nicolas DICHTEL wrote:

> When the stack check the mtu for this packet, it doesn't know the size of
> the overhead. So the total length of the packet don't include the size
> of the esp or ah header. The same bug appears when you run
> IPSEC in IPv4 transport mode over a 4in4 tunnel. A fix for this bug
> is to allow locally the fragmentation of the packet.

I've just tried the patch and unfortunately it doesn't fix the problem. :(

- Steve Hill (BSc)
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015
