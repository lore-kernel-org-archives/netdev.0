From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] net: sctp: bug fixing when sctp path recovers
Date: Wed, 13 Nov 2013 22:31:39 +0100
Message-ID: <5283EFBB.7010409@redhat.com>
References: <1384306486-31345-1-git-send-email-changxiangzhong@gmail.com> <5282E5F9.5000506@gmail.com> <5282E9EC.3090307@gmail.com> <52833BD3.4040003@redhat.com> <5283CDD1.3090309@gmail.com> <5283CEC3.4050507@redhat.com> <5283E5A8.3020809@gmail.com> <5283EDCF.20605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dreibh@simula.no
To: Chang <changxiangzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42002 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab3KMVbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 16:31:51 -0500
In-Reply-To: <5283EDCF.20605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 10:23 PM, Chang wrote:
[...]
> Let's say the following condition
> A - the initial revision
> B - something was wrong that introduced a bug
> C - latest revision
> MyFix - fixing the bug caused by B. Shall I specify B or C in the "fixes:" tag?
>
>
>          revision introduces a bug
>           |
> A -> B -> C ->MyFix
>                   |
>                   latest revision

You would specify B in the "Fixes:" tag, as B introduced this bug first.
In case there is no suitable git-blame information available in the current
tree (so that bug is pre Linux-2.6.12-rc2 which I believe on a quick look
that this seems the case), you can omit that. Then, just elaborate on the
commit message, and resubmit with feedback from Vlad included, too.

Thanks !
