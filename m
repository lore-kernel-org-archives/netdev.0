From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] adm8211: fix the possible pci cache line sizes inside
 switch-case
Date: Tue, 05 May 2015 15:01:53 -0700
Message-ID: <1430863313.9365.49.camel@perches.com>
References: <20150505214851.GA3013@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0238.hostedemail.com ([216.40.44.238]:42993 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751592AbbEEWB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 18:01:56 -0400
In-Reply-To: <20150505214851.GA3013@bytefire-computer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-05 at 22:48 +0100, Okash Khawaja wrote:
> The PCI cache line size value, stored in cline variable, was being
> compared against decimal values written as hex literals. This patch
> changes those literals to correct hex values. 

This is fine.

The grammar might be better as something like:

The PCI cache line size value was being compared against
decimal values prefixed with 0x.

Fix the literals to use the correct hex values. 

> Please note that this patch is on top of
> another code cleanup patch '[PATCH] adm8211: fix checkpatch errors for
> indentation and new line around switch-case'.

But this information doesn't belong here as
it would also be in a git log when someone
uses git am to apply it to a tree.

It'd be better to send a patch series using
"git format-email --cover-letter -2 -o <dir>"
and use git send-email for the series.
