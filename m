From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next 2/4] cgroup: bpf: Add BPF_MAP_TYPE_CGROUP_ARRAY
Date: Tue, 21 Jun 2016 18:15:57 -0700
Message-ID: <20160622011555.GB97149@ast-mbp.thefacebook.com>
References: <1466555002-1316296-1-git-send-email-kafai@fb.com>
 <1466555002-1316296-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tejun Heo <tj@kernel.org>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466555002-1316296-3-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 05:23:20PM -0700, Martin KaFai Lau wrote:
> Add a BPF_MAP_TYPE_CGROUP_ARRAY and its bpf_map_ops's implementations.
> To update an element, the caller is expected to obtain a cgroup2 backed
> fd by open(cgroup2_dir) and then update the array with that fd.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
