From: "David S. Miller" <davem@redhat.com>
Subject: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy device
 post.
Date: Sun, 25 Apr 2004 21:38:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040425213806.1edb6681.davem@redhat.com>
References: <wazza.87ad18jbdl.fsf@message.id>
	<1082427350.1034.70.camel@jzny.localdomain>
	<wazza.87fzayw1fy.fsf@message.id>
	<wazza.87fzaxmr6x.fsf@message.id>
	<wazza.87hdvddqxq.fsf@message.id>
	<1082639764.1059.81.camel@jzny.localdomain>
	<87oepjx65r.87n053x65r@87llknx65r.message.id>
	<1082719745.1057.27.camel@jzny.localdomain>
	<1082816083.1054.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, maxk@qualcomm.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082816083.1054.32.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24 Apr 2004 10:14:43 -0400
jamal <hadi@cyberus.ca> wrote:

> Jeff, Dave: Would it be fair to say when packets get injected into the
> stack by a netdev via netif_rx(), the skb headers are expected to be
> ponting into some specific places? I am not sure if theres a hard
> fastened rule defined anywhere.

What do ipv4 tunnels do?  They merely modify 'nh' and 'mac' ".raw" and
pass the packet in.
