From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Wed, 21 Oct 2015 13:04:41 -0700
Message-ID: <5627EFD9.9050805@plumgrid.com>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <56276261.7010201@huawei.com> <56277178.4080207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56277178.4080207@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 4:05 AM, Wangnan (F) wrote:
> I think we can
> make perf output raw data hexadamically at first.

that would be my suggestion as well.
print it as hex first and when llvm type info is available you can teach
perf to be smarter.
We're working on support for this feature in iovisor/bcc
without requiring extra llvm work, since we can generate
python classes on the fly from C code of bpf program.
