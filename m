From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 0/12] bpf: map pre-alloc
Date: Tue, 8 Mar 2016 08:38:53 -0800
Message-ID: <56DF001D.4000002@fb.com>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
 <56DE97A8.1050309@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56DE97A8.1050309@bmw-carit.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/8/16 1:13 AM, Daniel Wagner wrote:
>> Some time back Daniel Wagner reported crashes when bpf hash map is
>> >used to compute time intervals between preempt_disable->preempt_enable
>> >and recently Tom Zanussi reported a dead lock in iovisor/bcc/funccount
>> >tool if it's used to count the number of invocations of kernel
>> >'*spin*' functions. Both problems are due to the recursive use of
>> >slub and can only be solved by pre-allocating all map elements.
 >
> I gave it a short spin and lathist sample works just fine.

awesome. Thanks for testing!
