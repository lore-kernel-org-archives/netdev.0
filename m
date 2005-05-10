From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC] TCP congestion infrastructure
Date: Tue, 10 May 2005 15:06:18 +0100
Message-ID: <4280BFDA.3000909@ev-en.org>
References: <20050506173729.20140.93205.37072@galon.ev-en.org> <20050509162214.0a8c9ceb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050509162214.0a8c9ceb@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I rebased the H-TCP patches on my current work and 2.6.12-rc4 and put them in
> 	http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp/
> 
> Includes infrastructure and all the current variants: BIC, Westwood, Vegas
>     plus  H-TCP, Hybla


I compiled westwood and vegas as modules and got:

*** Warning: "tcpdiag_put" [net/ipv4/tcp_westwood.ko] undefined!
*** Warning: "tcpdiag_put" [net/ipv4/tcp_vegas.ko] undefined!

This is due to:

# CONFIG_IP_TCPDIAG is not set

in the .config.

Baruch
