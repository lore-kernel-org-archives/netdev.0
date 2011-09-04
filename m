From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Sun, 4 Sep 2011 09:12:21 +0200
Message-ID: <CA+icZUU25QMMCVT1VfF9XB0wrkppNmKQbHwoHDAQ-qV9bi+HqQ@mail.gmail.com>
References: <4E631032.6050606@intel.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:57103 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1IDHMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 03:12:22 -0400
Received: by qwi4 with SMTP id 4so3780652qwi.1
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2011 00:12:21 -0700 (PDT)
In-Reply-To: <4E631032.6050606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 4, 2011 at 7:44 AM, Yan, Zheng <zheng.z.yan@intel.com> wrote:
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
> in Unix socket's send and receive path) introduced a use-after-free bug.
> It passes the scm reference to the first skb. Skb(s) afterwards may
> reference freed data structure because the first skb can be destructed
> by the receiver at anytime. The fix is by passing the scm reference to
> the very last skb.
>

s/by passing/bypassing ?

> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> ---

Tested on i386 against linux-next (next-20110831).

- Sedat -
