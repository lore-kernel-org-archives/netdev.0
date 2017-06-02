From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Fri, 2 Jun 2017 07:33:58 -0700
Message-ID: <92f5537b-6450-15e7-a70b-b6d5d8161cca@fb.com>
References: <20170602020336.1062853-1-ast@fb.com>
 <20170602020336.1062853-2-ast@fb.com>
 <20170602080605.h42o7i27vmjrhz25@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602080605.h42o7i27vmjrhz25@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/2/17 1:06 AM, Peter Zijlstra wrote:
> Would it make sense to call perf_event_read_local() on the events here
> in order to weed out the -EOPNOTSUPP  ones?

excellent point! Finally understood your idea about that helper.
Will respin.
