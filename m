From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] skb: Augment skb_copy_datagram_iovec TRACE_EVENT to dump
 more info
Date: Mon, 31 Aug 2009 15:06:53 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908311506180.24907@gandalf.stny.rr.com>
References: <20090828203314.GA30417@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908281643190.25717@gandalf.stny.rr.com> <20090828231709.GA14063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, mingo@elte.hu
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:58872 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbZHaTGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 15:06:52 -0400
In-Reply-To: <20090828231709.GA14063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 28 Aug 2009, Neil Horman wrote:
> Thanks, Heres an updated patch with the nits fixed.  If you want to go over a
> better way to size strings when the source string isn't immediately available,
> I'll send  a subsequent patch to fix that
> 
> New version of the patch:
> 
> Augment the skb_copy_datagram_iovec TRACE_EVENT to provide same data output as
> the ftracer for skb numa node correlation that was recently removed.
> 
> Change notes:
> 
> 1) Cleaned up the nits Steven mentioned above

Looks good,

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
