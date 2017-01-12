From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 12:30:38 -0800
Message-ID: <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
References: <1484251157-245538-1-git-send-email-shannon.nelson@oracle.com>
 <1484252011.13165.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <cd152a9f-4855-a552-2b45-bd619436a628@oracle.com>
 <1484252733.13165.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Rob Gardner <rob.gardner@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484252733.13165.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/12/2017 12:25 PM, Eric Dumazet wrote:
> On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:
>
>>
>> I suspect that someplace, somebody is casting val to an int * or
>> something like that.
>
> Then that would be the bug. Can we root cause this please ?
>
>

Look in net/ipv4/tcp_fastopen.c:tcp_fastopen_cookie_gen() for the line

	 struct in6_addr *buf = (struct in6_addr *) tmp.val;

sln
