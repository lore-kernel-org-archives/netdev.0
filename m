From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix select() for SOCK_RAW sockets
Date: Tue, 7 Dec 2004 09:45:35 -0800
Message-ID: <20041207094535.11080082@dxpl.pdx.osdl.net>
References: <20041207003525.GA22933@linuxace.com>
	<20041207025218.GB61527@gaz.sfgoth.com>
	<20041207045302.GA23746@linuxace.com>
	<20041207054840.GD61527@gaz.sfgoth.com>
	<20041207150834.GA75700@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
        "David S. Miller"
 <davem@davemloft.net>, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20041207150834.GA75700@gaz.sfgoth.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Dec 2004 07:08:34 -0800
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Phil: Here's a real patch for you to test.  I actually left inet_dgram_ops
> alone since it's an exported symbol (two of the users just want the .do_ioctl
> value which is the same between SOCK_DGRAM and SOCK_RAW; the other is ipv6
> where it's clearly dealing with a UDP socket -- therefore I think its safest
> to leave inet_dgram_ops to have the UDP behavior)
> 
> Davem: I only tested that this doesn't break UDP; if it works for Phil and
> Stephen can verify that it doesn't break his bad-checksum UDP tests then
> please push it for 2.6.10.
> 

Thanks, I'll retest UDP today, but it looks right.
