From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Remove multiple assignment.
Date: Mon, 27 Mar 2017 14:08:27 +0200
Message-ID: <20170327120827.GA15676@salvia>
References: <20170325124946.GA9109@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170325124946.GA9109@arushi-HP-Pavilion-Notebook>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 25, 2017 at 06:19:47PM +0530, Arushi Singhal wrote:
> This patch removes multiple assignments.
> Done using coccinelle.
> @@
> identifier i1,i2;
> constant c;
> @@
> - i1=i2=c;
> + i1=c;
> + i2=c;

You have to explain why this is bad.
