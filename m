From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Tue, 23 May 2006 17:48:27 -0700
Message-ID: <20060523174827.0ce1943b.akpm@osdl.org>
References: <20060524001653.19403.31396.stgit@gitlost.site>
	<20060524002012.19403.50151.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54670 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932451AbWEXAss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:48:48 -0400
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060524002012.19403.50151.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +	for_each_cpu(i)

That's about to be deleted.  Please use for_each_possible_cpu().

That's if for_each_possible_cpu() is appropriate.  Perhaps it should be
using for_each_present_cpu(), or for_each_online_cpu().  That's why
for_each_cpu() is going away - to make people think about such things..

