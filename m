From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH trival -resend 1/2] bpf: clean up put_cpu_var usage
Date: Tue, 27 Sep 2016 16:02:11 -0700
Message-ID: <20160927230209.GA73876@ast-mbp>
References: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Shaohua Li <shli@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 08:42:41AM -0700, Shaohua Li wrote:
> put_cpu_var takes the percpu data, not the data returned from
> get_cpu_var.
> 
> This doesn't change the behavior.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
