From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [Acx100-devel] Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Thu, 9 Sep 2004 00:19:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409090019.21105.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <413F2D33.1000508@atheros.com> <200409082251.45771.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        acx100-devel@lists.sourceforge.net, greg chesson <greg@atheros.com>,
        hadi@cyberus.ca, jgarzik@pobox.com, jkmaline@cc.hut.fi,
        prism54-devel@prism54.org, sam@errno.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acx100-devel@lists.sourceforge.net, Vladimir Kondratiev <vkondra@mail.ru>,
        netdev@oss.sgi.com
In-Reply-To: <200409082251.45771.vkondra@mail.ru>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 08 September 2004 22:51, Vladimir Kondratiev wrote:
> Greg,
> you missed one important point. Besides data packets, that every driver now
> convert .11<->.3 using almost the same code, there is whole story of
> management. Many modern cards are "softmac" and do all management on host.
> I see no point for every driver to implement its own scanning and
> association. It is simply waste of resources.

This is exactly what I meant. We need generic 802.11 idioc^W management
handling. And maybe also tx rate control, ACK/retries for "completely-softmac"
cards like Atheros.

Full spectrum of possible fullmac......softmac designs are not trivial
to handle...

> To make step forward, I suggest the following:
>
> 1. Dave's code is at least year old. someone need to start maintain it,
> starting with update for current kernel infrastructure. Get it compile and
> load for 2.6.9, for example.

/me runs away and hides

> 2. To debug stack, you don't need real driver. I can write dummy .11 driver
> that will silently discard all Tx, and will provide some way for user level
> tool to simulate Rx (ioctl, netlink, does not really matter). For logic, it
> is sufficient. Later, when it will come to timing, performance etc, it will
> be easy to strip some real driver.
--
vda
