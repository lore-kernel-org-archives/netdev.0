From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Sun, 20 Jun 2010 11:49:13 -0700
Message-ID: <20100620114913.42d3650a@nehalam>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
	<20100619221611.784f7dbc@nehalam>
	<20100620095019.GA32223@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38233 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756568Ab0FTStP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jun 2010 14:49:15 -0400
In-Reply-To: <20100620095019.GA32223@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Jun 2010 11:50:20 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * Stephen Hemminger | 2010-06-19 22:16:11 [-0700]:
> 
> >I don't think this works because it breaks ABI compatibility for applications tha
> >use older versions.
> 
> Are you sure Stephen? It is a one-to-one mapping of the ABI but maybe it was
> too late yesterday ... ;-)

I was worried that the new (remapped codes) would overlap the ones from user
space.  Maybe best to have separate structures for the userspace API and the
kernel optimized filter instructions.  You could then do what ever transformations
you want there.
