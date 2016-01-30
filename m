From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 13:45:51 +0000
Message-ID: <20160130134550.GA5613@macbook.localdomain>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
 <1454159878-20706-3-git-send-email-tanure@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lucas Tanure <tanure@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454159878-20706-3-git-send-email-tanure@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.01, Lucas Tanure wrote:
> As suggested by checkpatch.pl:
> CHECK: Prefer kernel type 'uX' over 'uintX_t'

You might have noticed we have literally hundreds of them spread over 100
files in the netfilter code. We'll gradually change them when the code is
touched anyways.

>  net/ipv4/netfilter/ip_tables.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
