From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Net-next: ipv4: typo issue, remove erroneous
 semicolon
Date: Tue, 23 Apr 2013 01:16:04 -0400 (EDT)
Message-ID: <20130423.011604.1061769362231812796.davem@davemloft.net>
References: <517549F4.7030806@cogentembedded.com>
	<5175DFF9.4040000@asianux.com>
	<5175F5C3.8060503@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, pshelar@nicira.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830Ab3DWFQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 01:16:09 -0400
In-Reply-To: <5175F5C3.8060503@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Tue, 23 Apr 2013 10:45:23 +0800

> need remove erroneous semicolon, which is found by EXTRA_CFLAGS=-W.
> the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
> (by Pravin B Shelar <pshelar@nicira.com>  Mon Mar 25 14:49:35 2013)
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Do not put the destination GIT tree outside of the "[]" brackets.  Put
it inside the "[]" brackets, so it doesn't show up in the final commit
message.

Also, do not capitalize it, just "net-next" is fine.

Putting "(by Pravin B Shelar <pshelar@nicira.com>  Mon Mar 25 14:49:35 2013)"
is not what we asked for, we asked for the commit message header line
which for this commit would be ("GRE: Refactor GRE tunneling code.")

I want to know by what example you are doing these things?  Follow
the model of other successful patch submitters, such as Eric Dumazet,
Ben Hutchings, Thomas Graf, Simon Horman, etc. just to name a few.

Do exactly what they do, because I never have to tell those people how
to properly format their commit messages, header lines, and the patch
itself.

In your commit message body, properly capitalize your sentences.

This feedback applies to all of the patches you have submitted.  I'm
sorry I have to pick you apart so much, but if you're going to
contribute regularly you have to get this right, I can't be constantly
fixing up by hand every patch you submit.
