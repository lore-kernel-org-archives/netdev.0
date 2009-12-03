From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/7] Batched netns improvements.
Date: Thu, 03 Dec 2009 08:06:31 -0500
Message-ID: <1259845591.3766.30.camel@bigi>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:47466 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbZLCNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:06:28 -0500
Received: by vws30 with SMTP id 30so590926vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 05:06:34 -0800 (PST)
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-03 at 04:27 -0800, Eric W. Biederman wrote:
> This series of patches takes my simple 4k network namespace exit test
> from about 44s to 1.6s, with a minuscule increase in code side.

Nice.
I will test these as soon as they make it into net-next (just easier
for me given the setup).
I should confirm that:
The previous patches which are already in net-next from yesterday do
improve performance to under 1 minute. Can we call that a several-factor
improvement?;->

Are you planning to give some tender loving to the virtual devices 
as well (gre etc) or is that taken care of now you have a pernet batch
exit op?

cheers,
jamal

