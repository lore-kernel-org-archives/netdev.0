From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 10 Jul 2003 19:27:13 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057854432.3588.2.camel@hades>
References: <20030710154302.GE1722@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: CaT <cat@zip.com.au>
In-Reply-To: <20030710154302.GE1722@zip.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-07-10 at 18:43, CaT wrote:
> ip tunnel add sit1 mode sit remote 138.25.6.14
> ip link set sit1 up
> ip addr add 3ffe:8001:000c:ffff::37/127 dev sit1
>  ip route add ::/0 via 3ffe:8001:000c:ffff::36 
> RTNETLINK answers: Invalid argument

Try this:

ip route add ::/0 dev sit1

	MikaL
