From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
Subject: Re: [PATCH] Fix possible null pointer dereference in ariadne.c
Date: Wed, 02 Mar 2011 10:17:13 +0530
Message-ID: <4D6DCBD1.5030000@redhat.com>
References: <1298979207-11237-1-git-send-email-huzaifas@redhat.com> <20110301.115300.112595321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org, tj@kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757875Ab1CBErZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 23:47:25 -0500
In-Reply-To: <20110301.115300.112595321.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2011 01:23 AM, David Miller wrote:
> From: huzaifas@redhat.com
> Date: Tue,  1 Mar 2011 17:03:27 +0530
> 
>> +    *lance = (struct Am79C960*)dev->base_addr;
> 
> If you had actually compiled this, the compiler would have given
> you a warning shoing that the leading "*" in "*lance" is not
> appropriate for this assignment.
i did build, but looks like something happened after that :(
Sorry about the mess-up , will repost the patch.
