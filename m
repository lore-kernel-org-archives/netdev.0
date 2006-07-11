From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 11:00:09 +0200
Message-ID: <BAY103-F209936DACD91675B1D73DFB2680@phx.gbl>
References: <20060711075943.GB1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s33.bay0.hotmail.com ([65.54.246.105]:39119 "EHLO
	bay0-omc1-s33.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750785AbWGKJAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 05:00:11 -0400
In-Reply-To: <20060711075943.GB1490@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Mon, May 08, 2006 at 08:28:32AM +0000, Marco Berizzi wrote:
> >
> > root@Mimosa:~# ping 10.49.59.23
> > PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
> > 64 bytes from 10.49.59.23: icmp_seq=1 ttl=247 time=91.9 ms
> > 64 bytes from 10.49.59.23: icmp_seq=2 ttl=247 time=49.3 ms
> > 64 bytes from 10.49.59.23: icmp_seq=3 ttl=247 time=106 ms
> > 64 bytes from 10.49.59.23: icmp_seq=4 ttl=247 time=74.3 ms
> >
> > --- 10.49.59.23 ping statistics ---
> > 4 packets transmitted, 4 received, 0% packet loss, time 2998ms
> > rtt min/avg/max/mdev = 49.316/80.460/106.257/21.241 ms
> > root@Mimosa:~# cd /tmp/
> > root@Mimosa:/tmp# tcpdump -v -p -n ip host 10.49.59.23 >
> > /tmp/NULL-10.49.59.23 &
> > [1] 18981
> > root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB 
>(Ethernet),
> > capture size 96 bytes
> >
> > root@Mimosa:/tmp# ping 10.49.59.23
> > PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
> >
> > --- 10.49.59.23 ping statistics ---
> > 8 packets transmitted, 0 received, 100% packet loss, time 6999ms
> >
> > root@Mimosa:/tmp# fg
> > tcpdump -v -p -n ip host 10.49.59.23 >/tmp/NULL-10.49.59.23
> > 101 packets captured
> > 101 packets received by filter
> > 0 packets dropped by kernel
>
>Yes this is really weird.  The only thing I can think of is that it
>somehow managed to put some bogus entry into the conntrack table.
>What happens if you do
>
>grep 10.49.59.23 /proc/net/ip_conntrack
>
>before and after the tcpdump?

I'm not able to reproduce it :-[[[
Today mimosa is running 2.6.17.4, mon May 8 mimosa was running
2.6.16.12

If you want I could downgrade to 2.6.16.12 and see if I'm able
to reproduce it.
Sorry.


