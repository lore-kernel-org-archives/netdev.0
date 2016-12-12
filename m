From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH perf/core] samples/bpf: Drop unnecessary build targets.
Date: Mon, 12 Dec 2016 11:48:17 -0300
Message-ID: <20161212144817.GD5650@kernel.org>
References: <20161209175109.6779-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161209175109.6779-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Fri, Dec 09, 2016 at 09:51:09AM -0800, Joe Stringer escreveu:
> Commit f72179ef11db ("samples/bpf: Switch over to libbpf") added these
> two makefile changes that were unnecessary for switching samples to use
> libbpf. The extra make is already handled by the build dependency, and
> libbpf target doesn't build because it lacks main(). Remove these.
> 
> Reported-by: Wang Nan <wangnan0@huawei.com>
> Signed-off-by: Joe Stringer <joe@ovn.org>

Thanks, applied.

- Arnaldo
