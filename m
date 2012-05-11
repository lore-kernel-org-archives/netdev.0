From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net ipv6: Fixed checkpatch errors
Date: Fri, 11 May 2012 18:06:56 -0400 (EDT)
Message-ID: <20120511.180656.57416607962439989.davem@davemloft.net>
References: <1336755300-6821-1-git-send-email-cristian.chilipirea@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel.baluta@gmail.com
To: cristian.chilipirea@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336755300-6821-1-git-send-email-cristian.chilipirea@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cristian Chilipirea <cristian.chilipirea@gmail.com>
Date: Fri, 11 May 2012 19:55:00 +0300

> Fixed all of ERROR "foo* bar" should be "foo *bar"
> 
> Signed-off-by: Cristian Chilipirea <cristian.chilipirea@gmail.com>

Don't ever do this.

This has already been fixed in my net-next tree since April 1st, which
is more than a month ago.  What this means is that you wrote your
patch against something other than reality and your patch won't apply
at all.

All non-bug-fix networking patches should be against the net-next
tree, doing otherwise is at your own peril.
