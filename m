From: Alex Elder <alex.elder@linaro.org>
Subject: [PATCH 0/3] kernel.h: centrally define U32_MAX, etc.
Date: Thu, 26 Dec 2013 09:11:28 -0600
Message-ID: <52BC4720.1070904@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: reiserfs-devel@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel <ceph-devel@vger.kernel.org>, netdev@vger.kernel.org
To: Sage Weil <sage@inktank.com>, David Miller <davem@davemloft.net>,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, Al Viro <viro@ZenIV.linux.org.uk>, jeffm@suse.com,
	Steven Rostedt <rostedt@goodmis.org>,
	Andrew Morton <akpm@linux-foundation.org>, mst@redhat.com,
	Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:50844 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab3LZPLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 10:11:31 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so8758890ieb.36
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 07:11:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although types u32, s32, u16, s16 and so on are fundamental kernel
types, there is no central symbolic definition of their maximum and
minimum values.  In the past I've added and used such definitions
where I've needed them but they really belong in "kernel.h".

This series does this, in three steps.  The first makes existing
definitions be done conditionally; the second defines them in
"kernel.h"; and the third gets rid of the conditional definitions.

(These three can obviously be squashed into a single commit.)

    					-Alex

Alex Elder (3):
  conditionally define U32_MAX
  kernel.h: define u8, s8, u32, etc. limits
  remove extra definitions of U32_MAX

 fs/reiserfs/reiserfs.h      |    2 --
 include/linux/ceph/decode.h |   17 -----------------
 include/linux/kernel.h      |   13 +++++++++++++
 net/ipv4/tcp_illinois.c     |    1 -
 4 files changed, 13 insertions(+), 20 deletions(-)

-- 
1.7.9.5
