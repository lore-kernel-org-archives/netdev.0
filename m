From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 15:31:16 -0800
Message-ID: <20050125153116.3caa2745.davem@davemloft.net>
References: <20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
	<20050125014838.GA16637@gondor.apana.org.au>
	<20050125020118.GC31837@postel.suug.ch>
	<20050124180354.63ae600d.davem@davemloft.net>
	<20050125022431.GD31837@postel.suug.ch>
	<20050124194328.20a106de.davem@davemloft.net>
	<20050125143319.GF31837@postel.suug.ch>
	<20050125203607.GG31837@postel.suug.ch>
	<41F6B090.6020602@candelatech.com>
	<20050125211524.GH31837@postel.suug.ch>
	<41F6C4B6.20800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, herbert@gondor.apana.org.au, david@davidcoulson.net,
        kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41F6C4B6.20800@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 14:14:14 -0800
Ben Greear <greearb@candelatech.com> wrote:

> I'd leave everything to the driver.

I agree with Ben.  We've learned often in the past, especially
with VLAN, that it is often better to let the driver explicitly
say it can do something rather then assuming anything in
particular.
