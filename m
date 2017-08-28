From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix oops on allocation failure
Date: Mon, 28 Aug 2017 15:23:52 -0700 (PDT)
Message-ID: <20170828.152352.1578570740080935105.davem@davemloft.net>
References: <20170825202714.64ivixeindjph3z6@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, john.fastabend@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170825202714.64ivixeindjph3z6@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Aug 2017 23:27:14 +0300

> "err" is set to zero if bpf_map_area_alloc() fails so it means we return
> ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is not
> expecting NULL returns and will oops.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
