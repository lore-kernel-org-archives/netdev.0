From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: connecting ipv6 nodes throu' ipv4 network ....
Date: 20 Feb 2003 11:46:36 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220114636.21895.qmail@webmail29.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / $B5HF#1QL@\(B" <yoshfuji@wide.ad.jp>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My configuration.....
For Machine-1 
# ip -6 addr
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    inet6 ::1/128 scope host
8: epmac1: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    inet6 3ffe:1234::2/128 scope global
    inet6 fe80::a00:6ff:fe2b:9654/10 scope link

Machine-2
#ip -6 addr 
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    inet6 ::1/128 scope host
2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    inet6 3ffe:1234::1/128 scope global
    inet6 fe80::2b0:d0ff:fed2:65ff/10 scope link
    
I connected both the machines (directly) using cross cable and using sendip utility(ipv6 packet generator)

usage: sendip -p ipv6 -p tcp destaddr
i sent few packets with ipv6. 
I used ethereal to capture the data(in promiscous mode).

Here source=3ffe:1234::1 and dest=3ffe:1234::2.
when i send an ipv6 packet using sendip,
the source sends ICMPv6 Neighbor solicitation, 
but i dont see a reply from the dest,which is expected.

Is the method correct ?? Or other alternative method ?? Advice pls.

Regds,
-San
---------------------------------------------

On Thu, 20 Feb 2003 YOSHIFUJI Hideaki / $B5HF#1QL@(B wrote :
>In article <20030220104719.835.qmail@webmail32.rediffmail.com> (at 20 Feb 2003 10:47:19 -0000), "santosh kumar gowda" <ipv6_san@rediffmail.com> says:
>
> > I tried connecting only these two machines using a cross cable and
> > sending IPv6 packets. But it failed. Is it correct to do so ???
>
>Please show your exact configuration / command / output, etc.
>What do you mean by "it failed"?
>Any messages?
>
>--
>Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
>GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
>
>
 
