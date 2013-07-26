From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sysctl: range checking in
 do_proc_dointvec_ms_jiffies_conv
Date: Fri, 26 Jul 2013 14:23:00 -0700 (PDT)
Message-ID: <20130726.142300.2079205413428223270.davem@davemloft.net>
References: <cover.1374654531.git.ffusco@redhat.com>
	<cover.1374654531.git.ffusco@redhat.com>
	<de72e4265ab874b70b127011bb1ef8c2d27bfe63.1374654531.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760655Ab3GZVXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:23:02 -0400
In-Reply-To: <de72e4265ab874b70b127011bb1ef8c2d27bfe63.1374654531.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Wed, 24 Jul 2013 10:39:07 +0200

> When (integer) sysctl values are expressed in ms and have to be
> represented internally as jiffies. The msecs_to_jiffies function
> returns an unsigned long, which gets assigned to the integer.
> This patch prevents the value to be assigned if bigger than
> INT_MAX, done in a similar way as in cba9f3 ("Range checking in
> do_proc_dointvec_(userhz_)jiffies_conv").
> 
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>

Applied with the changes suggested by Sergei.
