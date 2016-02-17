From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Wed, 17 Feb 2016 18:14:40 +0100
Message-ID: <1455729280.5509.64.camel@redhat.com>
References: <20160216.154555.1807667652677383104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, pshelar@nicira.com,
	tgraf@suug.ch, jesse@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422669AbcBQROo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:14:44 -0500
In-Reply-To: <20160216.154555.1807667652677383104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-16 at 15:40 -0500, David Miller wrote:
> > Oh yes, I'm mixing different parts of the conversation.  We must
> > accept on RX zero checksum fields even for ipv6 because of the way the
> > VXLAN RFC is worded, correct.
> 
> Paolo, can you please respin your patch against 'net'?  I get rejects.

Sure. I'll resubmit soon,

Paolo
