From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable TCP_DEBUG and FASTRETRANS_DEBUG by default
Date: Mon, 17 Oct 2011 17:52:38 -0400 (EDT)
Message-ID: <20111017.175238.18474279385644215.davem@davemloft.net>
References: <1318883125-29500-1-git-send-email-dpmcgee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: dpmcgee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318883125-29500-1-git-send-email-dpmcgee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan McGee <dpmcgee@gmail.com>
Date: Mon, 17 Oct 2011 15:25:24 -0500

> If these are truly debug options, they should be turned off by default
> and can be tweaked if necessary. Fix one usage of the flag to use #if
> instead of #ifdef so defining to zero is acceptable.
> 
> Signed-off-by: Dan McGee <dpmcgee@gmail.com>

Illegal window shrinks are a serious issue, and the fact that everyone
will see those messages by default and sometimes report them has been
tremendously useful.
