From: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Subject: Re: "ss -p" segfaults (updated to 4.2)
Date: Sat, 10 Oct 2015 15:34:52 +0100
Message-ID: <5619220C.2030702@openmailbox.org>
References: <55AE15FE.6020802@openmailbox.org>
 <55AE16BD.40607@openmailbox.org> <20151006100933.GA2702@1wt.eu>
Reply-To: j.ps@openmailbox.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, schwab@linux-m68k.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.openmailbox.org ([62.4.1.42]:47193 "EHLO
	smtp8.openmailbox.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbbJJOnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 10:43:21 -0400
In-Reply-To: <20151006100933.GA2702@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willy,

It seems fine to me.
You may reword the commit message at will.

Thx,
Jose

On 2015-10-06 11:09, Willy Tarreau wrote:
> Hi guys,
> 
> I've updated Jose's patch to make it slightly simpler (eg: calloc instead
> of malloc+memset), and ported it to 4.2.0 which requires it as well, and
> attached it to this e-mail.
> 
> I can confirm that with this patch 4.1.1 doesn't segfault on me anymore.
> The commit message should be reworked I guess though everything's in it
> and I didn't want to modify his description.
> 
> Can it be merged as-is or should I reword the commit message and reference
> Jose as the fix reporter ? We should not let this bug live forever.
> 
> Thanks,
> Willy
> 
