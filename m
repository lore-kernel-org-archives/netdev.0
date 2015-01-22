From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: cls_basic: return from walking on
 match in basic_get
Date: Thu, 22 Jan 2015 10:01:36 +0000
Message-ID: <20150122100136.GB30859@casper.infradead.org>
References: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
 <1421920699-26556-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41155 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbAVKBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 05:01:37 -0500
Content-Disposition: inline
In-Reply-To: <1421920699-26556-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 10:58am, Daniel Borkmann wrote:
> As soon as we've found a matching handle in basic_get(), we can
> return it. There's no need to continue walking until the end of
> a filter chain, since they are unique anyway.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
