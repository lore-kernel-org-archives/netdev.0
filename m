From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Tue, 20 Jan 2015 00:01:15 +0100
Message-ID: <54BD8CBB.6040207@redhat.com>
References: <1421703363-3376-1-git-send-email-harouth@codeaurora.org> <54BD80D6.40402@redhat.com> <001501d03439$28f6d670$7ae48350$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbbASXBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 18:01:23 -0500
In-Reply-To: <001501d03439$28f6d670$7ae48350$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2015 11:42 PM, Harout Hedeshian wrote:
...
> Indeed, the patch is based on previous modifications to add sysctl/proc
> entries for IPv6 parameters. It is done this way to maintain consistency. Do
> you think we need a v3 without the changes to the sysctl_binary.c and
> corresponding changes in includes/uapi?

Yep, please.

> d9333196572 ("ipv6: Allow accepting RA from local IP addresses.") is as
> recent as June 2014.

Yeah, that looks wrong unfortunately.
