From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] include/linux/netfilter_bridge.h: header cleanup
Date: Sat, 29 Jul 2006 12:08:22 +0400
Message-ID: <20060729080822.GB6843@martell.zuzino.mipt.ru>
References: <20060729074545.GA6843@martell.zuzino.mipt.ru> <20060729005528.caadc6ff.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:10527 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422693AbWG2IIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 04:08:25 -0400
Received: by ug-out-1314.google.com with SMTP id m3so68902ugc
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2006 01:08:23 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060729005528.caadc6ff.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 29, 2006 at 12:55:28AM -0700, Andrew Morton wrote:
> On Sat, 29 Jul 2006 11:45:45 +0400
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > Header doesn't use anything from atomic.h.
> 
> 
> OK, but..
> 
> > It fixes headers_check warning:
> > 
> > include/linux/netfilter_bridge.h requires asm/atomic.h, which does not exist
> 
> asm/atomic.h _does_ exist.  What's up with that?

In tree, yes. In exported headers, no.

