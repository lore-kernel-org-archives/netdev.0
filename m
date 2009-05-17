From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] cls_cgroup: remove unneeded cgroup_lock
Date: Sun, 17 May 2009 13:58:56 -0700 (PDT)
Message-ID: <20090517.135856.123307111.davem@davemloft.net>
References: <200905122106.n4CL6ndX009858@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lizf@cn.fujitsu.com, lizf@cn.fujitsuc.com,
	menage@google.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755214AbZEQU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 16:58:58 -0400
In-Reply-To: <200905122106.n4CL6ndX009858@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 12 May 2009 13:47:33 -0700

> From: Li Zefan <lizf@cn.fujitsu.com>
> 
> We can remove this lock here, since we are in cgroup write handler and
> thus the cgrp is guaranteed to be valid, and no lock is needed when
> writing a u32 variable.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsuc.com>
> Acked-by: Paul Menage <menage@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
