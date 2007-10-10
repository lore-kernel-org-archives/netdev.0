From: jamal <hadi@cyberus.ca>
Subject: Re: [re] Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 09:12:43 -0400
Message-ID: <1192021963.4853.21.camel@localhost>
References: <20071010124510.M18768@visp.net.lb> <470CC97F.4000906@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:50439 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbXJJNMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 09:12:48 -0400
Received: by ik-out-1112.google.com with SMTP id c28so592879ika
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 06:12:47 -0700 (PDT)
In-Reply-To: <470CC97F.4000906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-10 at 14:45 +0200, Patrick McHardy wrote:

> OK, hrtimers are disabled on your system, but we still announce
> the usec clock resolution to userspace, which is used by HTB to
> calculate the burst rate. But actually that can't be the reason
> since that has already been the case in 2.6.22. Please post a diff
> of the bootlog from 2.6.22 and 2.6.23.

Any possible relation to clock source? logs seem to indicate acpi
source; how does tsc or jiffies do?

BTW, I could be wrong about this, but iirc in a xeon i had access to i
saw that i could not guarantee the same clock source would be selected
across reboots in about 2.6.22.

cheers,
jamal

