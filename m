From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/2] lib: introduce strncpy_from_unsafe()
Date: Fri, 28 Aug 2015 15:13:23 -0700
Message-ID: <55E0DD03.2000808@plumgrid.com>
References: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
 <1440791509-5450-2-git-send-email-ast@plumgrid.com>
 <20150828174813.23e6e78b@gandalf.local.home> <55E0DBE3.8010504@plumgrid.com>
 <20150828181141.6d974130@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150828181141.6d974130@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/28/15 3:11 PM, Steven Rostedt wrote:
> I personally prefer counting the NUL. I've had issues in the past with
> the strncpy_from_user() not counting it :-p

agreed. will respin with comment fixed. thank you much for review!
