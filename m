From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 22 May 2013 00:14:53 -0700 (PDT)
Message-ID: <20130522.001453.864958570289931561.davem@davemloft.net>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com>
	<20130517.141327.2084320693913331713.davem@davemloft.net>
	<1369198453.5722.12.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab3EVHOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 03:14:54 -0400
In-Reply-To: <1369198453.5722.12.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 22 May 2013 12:54:13 +0800

> Actually that is exactly what I _did_ in v1 or RFC, IIRC, it is David
> Stevens who prefers to use #ifdef inside these functions, so I changed
> it based on his suggestion.
> 
> I myself don't have any strong opinion here, either is okay, I just
> don't like changing it again and again. :)

The driver looks like complete shit with all the ifdefs in there,
this isn't the BSD kernel.

I do not want to seem them there at all.

You can abstract everything behind helper functions in a header
file, keep the mess there.
