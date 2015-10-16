From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net RESEND 0/2] overflow-arith: begin to add support for overflow builtins functions
Date: Fri, 16 Oct 2015 11:32:41 +0200
Message-ID: <1444987963-15327-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, dvyukov@google.com, davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I add a new header, linux/overflow-arith.h, as the central place to add
overflow and wrap-around checking functions. The reason I am doing so
is that it can make use of compiler supported builtin functions which
can leverage hardware.

As I need this for a fix in the ipv6 stack, which is also included in
this series, I propose to add it sooner than later over Davem's net
tree. This is also the reason why I start slowly with only the one
function I need at this time.

Thanks for reviewing!

Hannes Frederic Sowa (2):
  overflow-arith: begin to add support for overflow builtin functions
  ipv6: protect mtu calculation of wrap-around and infinite loop by
    rounding issues

 include/linux/compiler-gcc.h   |  4 ++++
 include/linux/overflow-arith.h | 18 ++++++++++++++++++
 net/ipv6/ip6_output.c          |  6 +++++-
 3 files changed, 27 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/overflow-arith.h

-- 
2.4.3
