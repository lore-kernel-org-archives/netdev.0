From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Mon, 12 Apr 2010 08:20:46 +0200
Message-ID: <m3ochpyywx.fsf@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	<1270813662.2623.85.camel@edumazet-laptop>
	<m3vdc0ztyc.fsf@ursa.amorsen.dk>
	<1270819762.2623.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:55574 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab0DLGVW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 02:21:22 -0400
In-Reply-To: <1270819762.2623.97.camel@edumazet-laptop> (Eric Dumazet's
	message of "Fri, 09 Apr 2010 15:29:22 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le vendredi 09 avril 2010 =C3=A0 14:33 +0200, Benny Amorsen a =C3=A9c=
rit :
>
>> Thank you very much for the help! I will report back whether it was =
the
>> hash buckets.
>
> OK
>
> You could try :
>
> ethtool -C eth0 tx-usecs 200 tx-frames 100 tx-frames-irq 100
> ethtool -C eth1 tx-usecs 200 tx-frames 100 tx-frames-irq 100
>
> (to reduce tx completion irqs)

Alas, even with the hash buckets I still have the same problem. Perhaps
slightly less severe, but it's still there.

I implemented the other changes you suggested as well except for the
ethtool -G. I may try to switch to net-next if I can find an easy way t=
o
make an RPM out of it.

Thank you for the help!

/proc/sys/net/netfilter/nf_conntrack_acct:1
/proc/sys/net/netfilter/nf_conntrack_buckets:1048576
/proc/sys/net/netfilter/nf_conntrack_checksum:1
/proc/sys/net/netfilter/nf_conntrack_count:43430
/proc/sys/net/netfilter/nf_conntrack_events:1
/proc/sys/net/netfilter/nf_conntrack_events_retry_timeout:15
/proc/sys/net/netfilter/nf_conntrack_expect_max:2048
/proc/sys/net/netfilter/nf_conntrack_generic_timeout:600
/proc/sys/net/netfilter/nf_conntrack_icmp_timeout:30
/proc/sys/net/netfilter/nf_conntrack_log_invalid:1
/proc/sys/net/netfilter/nf_conntrack_max:1048576
/proc/sys/net/netfilter/nf_conntrack_tcp_be_liberal:0
/proc/sys/net/netfilter/nf_conntrack_tcp_loose:1
/proc/sys/net/netfilter/nf_conntrack_tcp_max_retrans:3
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_close:10
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_close_wait:60
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established:432000
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_fin_wait:120
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_last_ack:30
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_max_retrans:300
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_recv:60
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_sent:120
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_time_wait:120
/proc/sys/net/netfilter/nf_conntrack_tcp_timeout_unacknowledged:300
/proc/sys/net/netfilter/nf_conntrack_udp_timeout:30
/proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream:180


/Benny
