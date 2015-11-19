From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH iproute2 0/2] Build fixes for the musl C library
Date: Thu, 19 Nov 2015 22:05:38 +0100
Message-ID: <1447967140-29909-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:51871 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934121AbbKSVF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:05:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following two patches fixing build issues that occur when trying
to build iproute2 with the musl C library (http://musl-libc.org).

Thanks,

Thomas

Thomas Petazzoni (2):
  Avoid in6_addr redefinition
  Add missing <sys/types.h> include

 include/iptables_common.h            | 2 ++
 include/libiptc/ipt_kernel_headers.h | 2 --
 include/linux/if_bridge.h            | 1 -
 include/linux/netfilter.h            | 2 --
 include/linux/xfrm.h                 | 1 -
 5 files changed, 2 insertions(+), 6 deletions(-)

-- 
2.6.3
