From: Stephen Hemminger <stephen@networkplumber.org>
Subject: netvsc NAPI
Date: Wed, 22 Feb 2017 09:33:16 -0800
Message-ID: <20170222093316.303203c3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34238 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932441AbdBVRdT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:33:19 -0500
Received: by mail-pg0-f44.google.com with SMTP id 1so3634370pgi.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 09:33:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAPI for netvsc is ready but the merge coordination is a nuisance.

Since netvsc NAPI support requires other changes that are proceeding through
GregKH's char-misc tree. I would like to send the two patches after current net-next
and char-misc-next are merged into Linus's tree.

Need these (at a minimum) these changes

 6e47dd3e2938 ("vmbus: expose hv_begin/end_read")
 5529eaf6e79a ("vmbus: remove conditional locking of vmbus_write")
 b71e328297a3 ("vmbus: add direct isr callback mode")
 631e63a9f346 ("vmbus: change to per channel tasklet")
 37cdd991fac8 ("vmbus: put related per-cpu variable together")

Please let me know when linux-net is up to date with these.
