From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] use smp_load_acquire()/smp_store_release()
Date: Wed, 29 Oct 2014 07:49:19 -0700
Message-ID: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Ko <stephen.s.ko@intel.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:54597 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933329AbaJ2OtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 10:49:18 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so3292042pab.22
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 07:49:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander

The memory barriers added in commit
b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
("net: Add memory barriers to prevent possible race in byte queue
limits")

have heavy cost.

It seems we could use smp_load_acquire() and smp_store_release()
instead ?

I'll post a patch later today. I would be interested if someone was able
to test it, as your commit apparently was tested and known to fix a
reproducible race.

Thanks !
