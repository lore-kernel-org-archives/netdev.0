From: Andrew McGregor <andrew@indranet.co.nz>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Thu, 09 Jan 2003 08:52:19 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <74190000.1042055539@localhost.localdomain>
References: <20030108150201.GA30490@wiggy.net>
 <Pine.LNX.4.44.0301081718340.4542-100000@dns.toxicfilms.tv>
 <20030108170139.GL22951@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>, linux-kernel@vger.kernel.org
In-Reply-To: <20030108170139.GL22951@wiggy.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Selective ACK is mandatory in IPv6 and uses a somewhat different algorithm, 
so you shouldn't be seeing nearly as many ACKs as an IPv4 client would do 
by default.

Andrew

--On Wednesday, January 08, 2003 18:01:39 +0100 Wichert Akkerman 
<wichert@wiggy.net> wrote:

> Previously Maciej Soltysiak wrote:
>> I seem to be getting better results than you, i think that it is not an
>> issue of ipv6 implementation but simply the case of time sensitive
>> traffic fighting with other Internet traffic over tunnels through ipv4
>> networks.
>
> Actually, I don't follow this. How could any kind of traffic shaping
> result in my client not sending ACKs, which is what the tcpdump
> seems to indicate? I can understand packets being dropped which
> would result in retransmits, but that is not the case here.
>
> Wichert.
>
> (usual I'm-no-network-guru-and-might-be-misreading-things disclaimer here)
>
> --
> Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
> A random hacker
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
