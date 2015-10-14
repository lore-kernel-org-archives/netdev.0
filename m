From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH V2 1/2] bpf: control the trace data output on current cpu
 when perf sampling
Date: Wed, 14 Oct 2015 21:49:39 +0800
Message-ID: <201510142113.R6QU6uqp%fengguang.wu@intel.com>
References: <1444826277-94060-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, ast@plumgrid.com, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, xiakaixu@huawei.com, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444826277-94060-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kaixu,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Kaixu-Xia/bpf-enable-disable-events-stored-in-PERF_EVENT_ARRAY-maps-trace-data-output-when-perf-sampling/20151014-204158
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> kernel/trace/bpf_trace.c:239:29: sparse: symbol 'bpf_perf_event_sample_control_proto' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
