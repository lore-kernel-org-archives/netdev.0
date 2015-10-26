From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Mon, 26 Oct 2015 14:32:59 +0100
Message-ID: <1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
 <20151026131928.GA1820@netboy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:44373 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511AbbJZNc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 09:32:59 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 5EF5820270
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 09:32:59 -0400 (EDT)
In-Reply-To: <20151026131928.GA1820@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Oct 26, 2015, at 14:19, Richard Cochran wrote:
> On Mon, Oct 26, 2015 at 01:51:37PM +0100, Hannes Frederic Sowa wrote:
> > netstamp_needed is toggled for all socket families if they request
> > timestamping. But some protocols don't need the lower-layer timestamping
> > code at all. This patch starts disabling it for af-unix.
> 
> What problem is this patch trying to solve?

netstamp_needed is a static-key which enables timestamping code in the
networking stack receive functions for every packet, while it is not
needed for AF_UNIX/LOCAL. So it is merely a small performance
enhancement.

Bye,
Hannes
