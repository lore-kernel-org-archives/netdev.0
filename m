From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Thu, 9 Jan 2003 23:21:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030109222155.GE22951@wiggy.net>
References: <20030108150201.GA30490@wiggy.net> <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv> <20030108170139.GL22951@wiggy.net> <1042150352.4688.15.camel@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <1042150352.4688.15.camel@devil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Mika Liljeberg wrote:
> Looking at your trace it seems that the receiving machine is dropping
> all packets that do not have traffic class set. Note that all segments
> received with [class 0x2] get properly acked. The others probably don't
> get to TCP at all. You might want to check your filters and QoS
> policies.

I don't have any filters and QoS support isn't even enabled in this
kernel.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
A random hacker
