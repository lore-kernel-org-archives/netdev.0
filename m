From: Joe Perches <joe@perches.com>
Subject: Re: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Wed, 04 Sep 2013 21:53:37 -0700
Message-ID: <1378356817.1787.77.camel@joe-AO722>
References: <20130905042045.GD15824@redhat.com>
	 <20130905.003907.664285605568829856.davem@davemloft.net>
	 <20130905044318.GA22806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36670 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753224Ab3IEExk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 00:53:40 -0400
In-Reply-To: <20130905044318.GA22806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 00:43 -0400, Dave Jones wrote:
> On Thu, Sep 05, 2013 at 12:39:07AM -0400, David Miller wrote:
>  > From: Dave Jones <davej@redhat.com>
>  > Date: Thu, 5 Sep 2013 00:20:45 -0400
>  > 
>  > > What's the intent here ?
>  > 
>  > This stuff is great, do you have a script that looks for this false
>  > indentation pattern?
> 
> Coverity.

Good stuff.

> I'm doing daily builds with it now, in the hope of trying
> to catch things faster, but there's a *ton* of old stuff in there
> like this that needs sorting through, because it seems to have strange
> of notions of what a 'new' bug is.

I think scripts/coccinelle/misc/ifcol.cocci
does something similar.
