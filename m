From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 13:25:32 +0000
Message-ID: <20150326132532.GB20404@casper.infradead.org>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51763 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbCZNZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 09:25:35 -0400
Content-Disposition: inline
In-Reply-To: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/15 at 01:53pm, Jiri Pirko wrote:
> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
> 
> This patch is only the first step. There is a lot of potential performance
> improvements possible to implement. Also a lot of features are missing
> now. They will be addressed in follow-up patches.
> 
> To the name of this classifier, I believe that "cls_openflow" is pretty
> accurate. It is actually a OpenFlow classifier.

My feedback on this was that this could be misleading because
cls_openflow does not make the kernel an OpenFlow switch (neither
does OVS). I can see the relation to some of the match fields as
specified by OpenFlow but there is no relation to the wire protocol
itself or any of the other OpenFlow specific concepts such as flow
tables, group tables, counters, actions, etc.

That said, I can see what you mean by it and I think if we make this
clear in the description and manual page that might be enough to
avoid confusion.
