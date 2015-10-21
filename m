From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 17:25:02 +0200
Message-ID: <20151021172502.63220dbb@griffin>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
	<20151021.074332.1709904332480699231.davem@davemloft.net>
	<20151021164613.24650836@griffin>
	<20151021.083214.534622235927401863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754915AbbJUPZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 11:25:06 -0400
In-Reply-To: <20151021.083214.534622235927401863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2015 08:32:14 -0700 (PDT), David Miller wrote:
> As you say the apps are broken, so file a bug and have them fixed.
> 
> The assumption is clearly invalid, so apps cannot make such an
> assumption.

Does it mean you would be okay with a patch that always allocates and
assigns a new ifindex in the target netns when interface is moved
between name spaces?

 Jiri

-- 
Jiri Benc
