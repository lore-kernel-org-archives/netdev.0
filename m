From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Optimize loopback stats
Date: Tue, 15 Mar 2005 16:18:42 -0800
Message-ID: <42377B62.6070606@us.ibm.com>
References: <200503151819_MC3-1-98A4-43AC@compuserve.com> <42377947.5090207@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <76306.1226@compuserve.com>,
        Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>,
        linux-netdev <netdev@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <42377947.5090207@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hmm, I see the following in your patch:
> 
> +               stats->rx_bytes   += lb_stats->rx_tx_bytes;
> +               stats->tx_bytes    = stats->rx_bytes;
> 
> Doesn't that mean RX is now twice what it should be
> and so is TX? They are separately reported, but if
> so, their real value should be half of rx_tx_bytes
> each, correct?

Ah, just beat me silly with a cluestick.
I see what you're doing now..it's fine.

thanks,
Nivedita
