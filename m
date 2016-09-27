From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/7] proc: Reduce cache miss in snmp_seq_show
Date: Tue, 27 Sep 2016 09:45:51 -0400 (EDT)
Message-ID: <20160927.094551.1178979867316917587.davem@davemloft.net>
References: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
        <1474877355-12920-3-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        marcelo.leitner@gmail.com
To: hejianet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474877355-12920-3-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia He <hejianet@gmail.com>
Date: Mon, 26 Sep 2016 16:09:10 +0800

> +static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
> +{
> +	int i;
> +	unsigned long buff[TCPUDP_MIB_MAX];
> +	struct net *net = seq->private;

Please always order local variables from longest to shortest
line.

Please audit your entire patch series for this problem.

Thanks.
