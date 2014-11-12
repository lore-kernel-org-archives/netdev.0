From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] selftests/net: psock_fanout seg faults in
 sock_fanout_read_ring()
Date: Tue, 11 Nov 2014 21:44:02 -0500 (EST)
Message-ID: <20141111.214402.693686900755542775.davem@davemloft.net>
References: <1415725453-6549-1-git-send-email-shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shuahkh@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415725453-6549-1-git-send-email-shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuahkh@osg.samsung.com>
Date: Tue, 11 Nov 2014 10:04:13 -0700

> The while loop in sock_fanout_read_ring() checks mmap region
> bounds after access, causing it to segfault. Fix it to check
> count before accessing header->tp_status. This problem can be
> reproduced consistently when the test in run as follows:
> 
>     make -C tools/testing/selftests TARGETS=net run_tests
>     or
>     make run_tests from tools/testing/selftests
>     or
>     make run_test from tools/testing/selftests/net
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>

Definitely looks correct to me, applied, thanks.
