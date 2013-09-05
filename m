From: Dave Jones <davej@redhat.com>
Subject: Re: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Thu, 5 Sep 2013 00:43:18 -0400
Message-ID: <20130905044318.GA22806@redhat.com>
References: <20130905042045.GD15824@redhat.com>
 <20130905.003907.664285605568829856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab3IEEn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 00:43:26 -0400
Content-Disposition: inline
In-Reply-To: <20130905.003907.664285605568829856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 05, 2013 at 12:39:07AM -0400, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Thu, 5 Sep 2013 00:20:45 -0400
 > 
 > > What's the intent here ?
 > 
 > This stuff is great, do you have a script that looks for this false
 > indentation pattern?

Coverity. I'm doing daily builds with it now, in the hope of trying
to catch things faster, but there's a *ton* of old stuff in there
like this that needs sorting through, because it seems to have strange
of notions of what a 'new' bug is.

	Dave
