From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement
 bpf_perf_event_sample_enable/disable() helpers
Date: Tue, 13 Oct 2015 22:14:39 -0700
Message-ID: <561DE4BF.6090306@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
 <561C0A1E.2080500@plumgrid.com> <561C7A1F.6040702@huawei.com>
 <561C7CDA.8050004@plumgrid.com> <561C7FBE.4000104@huawei.com>
 <561C85BB.3000505@plumgrid.com> <561C89EC.8030303@huawei.com>
 <561C9361.6090104@plumgrid.com> <561CE2DB.2030409@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com,
	netdev@vger.kernel.org
To: He Kuang <hekuang@huawei.com>, "Wangnan (F)" <wangnan0@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561CE2DB.2030409@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/15 3:54 AM, He Kuang wrote:
> If we want perf to reflect as soon as our sample event be generated,
> --no-buffering should be used, but this option has a greater
> impact on performance.

no_buffering doesn't have to be applied to all events obviously.
