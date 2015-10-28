From: Loganaden Velvindron <logan@elandsys.com>
Subject: Re: [PATCH net-next] net: bridge: use vzalloc() instead of vmalloc()
 as counterstmp is not cleared before it is used in get_counters().
 counterstmp might be leaked partially when it is sent to userland later on.
Date: Wed, 28 Oct 2015 11:34:29 -0700
Message-ID: <20151028183429.GA19990@mx.elandsys.com>
References: <20151028155654.GA2775@mx.elandsys.com>
 <56310F8C.2080201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:62579 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191AbbJ1Sei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 14:34:38 -0400
Content-Disposition: inline
In-Reply-To: <56310F8C.2080201@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 09:10:20PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
>    Your subject is too long, it should have been placed in the changelog
> partially. You you didn't sign off on the patch, so it can't applied.
> 
> MBR, Sergei

Thank you. Please reject this patch. I re-sent a proper one in another mail.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
