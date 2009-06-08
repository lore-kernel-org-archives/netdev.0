From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: tg3 stops working when NFS is involved
Date: Sun, 7 Jun 2009 22:18:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.01.0906072215000.6439@bogon>
References: <alpine.DEB.2.01.0906072115420.6439@bogon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61197 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbZFHFSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 01:18:50 -0400
In-Reply-To: <alpine.DEB.2.01.0906072115420.6439@bogon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 7 Jun 2009, Christian Kujau wrote:
> anything else - so, I figure it's not a client problem. And I'm not sure 
> if it's NFS problem either, because restarting the NFS server doesn't do 
> anything, I really have to rmmod/modprobe the tg3 module. OTOH, I cannot 
> reproduce this without NFS: running e.g. iperf (TCP, UDP) did not trigger 
> it.

Just tested with Samba - after a few megabytes of transmitted data, tg3 stops 
working, with no messages printed in the kernel log :-\

I don't know why iperf does not trigger it though....

Christian.
-- 
BOFH excuse #271:

The kernel license has expired
