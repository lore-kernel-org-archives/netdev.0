From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: connecting ipv6 nodes throu' ipv4 network ....
Date: 20 Feb 2003 12:15:46 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220121546.27110.qmail@webmail28.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Maciej Soltysiak" <solt@dns.toxicfilms.tv>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

when i connect my two IPv6 hosts using a cross cable, i'm unable 
to
ping and the ethernet link seems to be down.
Also, one machine has bridged-ethernet.
Is it correct to do so ??

pls help.
-san
-----------------------------

On Thu, 20 Feb 2003 Maciej Soltysiak wrote :
> > IPv6 addr of machine-1 is 3ff3:1234::1
> > IPv6 addr of machine-2 is 3ff3:1234::2
> > My LAN is based on IPv4.
> > To make these IPv6-hosts to communicate on the LAN, what
> > configuration do i need to make ???
>
>Well, as in ipv4 the hosts need an address and routing:
>machine-1:
># ip addr add 3ff3:1234::1 dev eth0
># ip route add 3ffe:1234/mask dev eth0
>
>machine-2:
># ip addr add 3ff3:1234::1 dev eth0
># ip route add 3ff3:1234/mask dev eth0
>
>If you have a route to the ip6 world, then add to them:
># ip route add 2001::/3 via (your:ip6:router:address) dev eth0
>
> > I tried connecting only these two machines using a cross cable 
>and
> > sending IPv6 packets. But it failed. Is it correct to do so 
>???
>Should work, maybe the cables are bad?
>
>Regards,
>Maciej
>
