From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2][AX25] make ax25_queue_xmit a net_device parameter
Date: 04 Apr 2005 16:11:36 -0400
Message-ID: <1112645495.1078.40.camel@jzny.localdomain>
References: <20050404195030.GJ640@conectiva.com.br>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <20050404195030.GJ640@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


You probably wanna set skb->input_dev in ax25_type_trans() as well
something like:
skb->input_dev = skb->dev = dev

cheers,
jamal

On Mon, 2005-04-04 at 15:50, Arnaldo Carvalho de Melo wrote:
> Hi David, Ralf,
> 
> 	I'm trying to get back to the work of reducing the number of direct
> references to skb->{h,nh,raw}, that eventually will become just a void
> pointer.
> 
> 	Available at:
> 
> bk://kernel.bkbits.net/acme/sk_buff-2.6
> 
> Regards,
> 
> - Arnaldo
