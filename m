From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Tue, 27 Oct 2015 11:11:58 +0100
Message-ID: <20151027101157.GA1850@netboy>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
 <20151026131928.GA1820@netboy>
 <1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38434 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbJ0KMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 06:12:02 -0400
Received: by wicll6 with SMTP id ll6so152577993wic.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 03:12:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 02:32:59PM +0100, Hannes Frederic Sowa wrote:
> On Mon, Oct 26, 2015, at 14:19, Richard Cochran wrote:
> > On Mon, Oct 26, 2015 at 01:51:37PM +0100, Hannes Frederic Sowa wrote:
> > > netstamp_needed is toggled for all socket families if they request
> > > timestamping. But some protocols don't need the lower-layer timestamping
> > > code at all. This patch starts disabling it for af-unix.
> > 
> > What problem is this patch trying to solve?
> 
> netstamp_needed is a static-key which enables timestamping code in the
> networking stack receive functions for every packet, while it is not
> needed for AF_UNIX/LOCAL. So it is merely a small performance
> enhancement.

Are there any numbers that show the effect of this enhancement?

Thanks,
Richard
