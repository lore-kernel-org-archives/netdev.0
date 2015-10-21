From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 08:56:35 -0700 (PDT)
Message-ID: <20151021.085635.1582760365341524949.davem@davemloft.net>
References: <20151021164613.24650836@griffin>
	<20151021.083214.534622235927401863.davem@davemloft.net>
	<20151021172502.63220dbb@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbbJUPkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:40:12 -0400
In-Reply-To: <20151021172502.63220dbb@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 21 Oct 2015 17:25:02 +0200

> On Wed, 21 Oct 2015 08:32:14 -0700 (PDT), David Miller wrote:
>> As you say the apps are broken, so file a bug and have them fixed.
>> 
>> The assumption is clearly invalid, so apps cannot make such an
>> assumption.
> 
> Does it mean you would be okay with a patch that always allocates and
> assigns a new ifindex in the target netns when interface is moved
> between name spaces?

I think you're misunderstanding me if you're still recommending
kernel changes.

I'm plainly saying to remove the assumption in the apps.

If you don't show me exactly how some kernel change can lead to
the apps implementing things properly, without the invalid
assumptions, then I can only assume you didn't hear what I
said.
