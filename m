From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix oops on allocation failure
Date: Fri, 25 Aug 2017 18:05:58 -0700
Message-ID: <20170826010556.rxoyckykv6bwg47o@ast-mbp>
References: <20170825202714.64ivixeindjph3z6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825202714.64ivixeindjph3z6@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 11:27:14PM +0300, Dan Carpenter wrote:
> "err" is set to zero if bpf_map_area_alloc() fails so it means we return
> ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is not
> expecting NULL returns and will oops.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

good catch. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>

