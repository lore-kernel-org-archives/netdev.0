From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH 2/2][AX25] make ax25_queue_xmit a net_device parameter
Date: Mon, 4 Apr 2005 20:08:39 -0300
Message-ID: <39e6f6c70504041608707cb02f@mail.gmail.com>
References: <20050404195030.GJ640@conectiva.com.br>
	 <1112645495.1078.40.camel@jzny.localdomain>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112645495.1078.40.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 04 Apr 2005 16:11:36 -0400, jamal <hadi@cyberus.ca> wrote:
> 
> You probably wanna set skb->input_dev in ax25_type_trans() as well
> something like:
> skb->input_dev = skb->dev = dev

Yup, forgot about this one in this patch, but I want right now is mostly to
reduce open coding all around while maintaining the same behaviour, in
time we can eventually see a better abstraction for this set of operations,
it should also set skb->protocol internally and not return a value to set
skb->protocol, etc. :-)

- Arnaldo
