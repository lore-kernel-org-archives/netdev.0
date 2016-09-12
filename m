From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/2] uapi: include time.h from errqueue.h
Date: Mon, 12 Sep 2016 13:05:28 -0400
Message-ID: <1473699930-58865-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        john.stultz@linaro.rg, bmoses@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

It was reported that linux/errqueue.h requires linux/time.h, but that
adding the include directly may cause userspace conflicts between
linux/time.h and glibc time.h:

  https://lkml.org/lkml/2016/7/10/10

Address the conflicts using the standard libc-compat approach, then
add the #include to errqueue.h

The first patch is a resubmit. It was previously submitted to
tip/timers/core, but given the commit history, the maintainer
suggested this tree, instead.

  https://lkml.org/lkml/2016/8/10/748

This also allows sending the follow-up as part of the patchset.

Willem de Bruijn (2):
  uapi glibc compat: make linux/time.h compile with user time.h files
  errqueue: include linux/time.h

 include/uapi/linux/errqueue.h    |  1 +
 include/uapi/linux/libc-compat.h | 50 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/time.h        | 15 ++++++++++++
 3 files changed, 66 insertions(+)

-- 
2.8.0.rc3.226.g39d4020
