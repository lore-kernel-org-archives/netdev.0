From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 1/2] netfilter: nf_ct_expect:
 nf_ct_expect_related_report(): Return zero on success,
Date: Wed, 22 Feb 2017 10:47:22 +0100
Message-ID: <20170222094722.GC1581@salvia>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fgao@ikuai8.com,
        netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2017 at 03:25:21PM -0800, Jarno Rajahalme wrote:
> Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
> returns void") inadvertently changed the successful return value of
> nf_ct_expect_related_report() from 0 to 1, which caused openvswitch
> conntrack integration fail in FTP test cases.
> 
> Fix this by always returning zero on the success code path.

Please, Cc netfilter-devel for your netfilter patches.

I can pick these patches via nf.git tree.

Thank you.
