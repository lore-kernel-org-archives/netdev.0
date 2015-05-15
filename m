From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 0/3] tc state machinery cleanups
Date: Fri, 15 May 2015 15:11:53 +0200
Message-ID: <5555F099.9000605@iogearbox.net>
References: <1431679850-31896-1-git-send-email-fw@strlen.de> <5555DA48.6010208@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39989 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934365AbbEONL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 09:11:57 -0400
In-Reply-To: <5555DA48.6010208@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 01:36 PM, Jamal Hadi Salim wrote:
...
> It would be useful to keep readability for the rest of the code the
> way it was - change the definition of the macros.
...
> Note: The macros are fugly - but there are better tools these days to
> make them easier to read so de-uglifying could be part of the goal.

Yep, they are fugly. :) Only adapting the definitions of the macros then
pointing to the skb bits of skb_tc_state (or however it's called eventually)
could certainly be an intermin step, where a follow-up could get rid of
the macros for the kernel eventually as part of the de-uglifying. Is that
what you mean?
