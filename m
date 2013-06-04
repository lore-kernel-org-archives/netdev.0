From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Tue, 4 Jun 2013 09:11:50 -0700
Message-ID: <20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:43803 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab3FDQLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 12:11:55 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so417361pad.5
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 09:11:55 -0700 (PDT)
In-Reply-To: <1370332874-584-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Jun 2013 12:01:14 +0400
Andrey Vagin <avagin@openvz.org> wrote:

> Otherwise a program executed by "ip netns exec" has two extra
> descriptors.
> 
> $ ip netns exec test /bin/bash
> $ lsof -p $$
> ...
> bash    817 root    0u   CHR  136,0       0t0          3 /dev/pts/0
> bash    817 root    1u   CHR  136,0       0t0          3 /dev/pts/0
> bash    817 root    2u   CHR  136,0       0t0          3 /dev/pts/0
> bash    817 root    3u  sock    0,6       0t0      13386 protocol: NETLINK
> bash    817 root    4r   REG    0,3         0 4026532155 net
> bash    817 root  255u   CHR  136,0       0t0          3 /dev/pts/0

Applied
