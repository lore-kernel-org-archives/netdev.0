From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH] IPv6: Cleanup of net/ipv6/reassambly.c
Date: Sun, 12 Mar 2006 08:17:07 +0100
Message-ID: <200603120817.08528.ioe-lkml@rameria.de>
References: <200603120049.49294.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751481AbWCLHV3@vger.kernel.org>
To: "YOSHIFUJI Hideaki / =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?="
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <200603120049.49294.ioe-lkml@rameria.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sunday, 12. March 2006 00:49, Ingo Oeser wrote:
> From: Ingo Oeser <ioe-lkml@rameria.de>
> 
> Two minor cleanups:
> 
> 1. Using kzalloc() in fraq_alloc_queue() 
>    saves the memset() in ipv6_frag_create().
> 
> 2. Invert sense of if-statements to streamline code.
>    Inverts the comment, too.
> 

These are against net-2.6.17 of course.

I also compile tested this and my other kzalloc() changes.

Forgot to mention this yesterday...


Regards

Ingo Oeser
