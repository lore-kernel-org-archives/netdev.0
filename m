From: David Miller <davem@davemloft.net>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 04 Dec 2015 16:37:53 -0500 (EST)
Message-ID: <20151204.163753.594151588498690658.davem@davemloft.net>
References: <20151204.142651.968075964630586979.davem@davemloft.net>
	<CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
	<20151204203522.GB64517@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com, ryabinin.a.a@gmail.com
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204203522.GB64517@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 4 Dec 2015 12:35:23 -0800

> On Fri, Dec 04, 2015 at 08:48:57PM +0100, Dmitry Vyukov wrote:
>> 
>> For example, a compiler can assume that result of left shift is larger
>> or equal to first operand, which in turn can allow it to elide some
>> bounds check in code, which in turn can lead to an exploit. I am not
>> saying that this particular pattern is present in the code, what I
>> want to say is that such undefined behaviors can lead to very
>> unpredictable and unexpected consequences.
> 
> Within bpf it cannot.
> shift is not used in any memory or bounds operations.
> so reg <<= 1234 cannot be exploited.

+1
