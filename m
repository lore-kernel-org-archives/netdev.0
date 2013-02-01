From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] packet: fix leakage of tx_ring memory
Date: Fri, 01 Feb 2013 17:48:04 +0100
Message-ID: <510BF1C4.4050108@redhat.com>
References: <1359727032-7999-1-git-send-email-phil.sutter@viprinet.com> <510BE7B4.8070202@redhat.com> <20130201162120.GA5543@philter.vipri.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Johann Baudy <johann.baudy@gnu-log.net>
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757127Ab3BAQsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 11:48:11 -0500
In-Reply-To: <20130201162120.GA5543@philter.vipri.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 05:21 PM, Phil Sutter wrote:
> On Fri, Feb 01, 2013 at 05:05:08PM +0100, Daniel Borkmann wrote:

>> I think it would be easier / more readable to simply move the memset into
>> the two ifs than introducing an extra function for just doing that.
>
> Yes, this was just how my fix looked like initially, but I didn't like
> the resulting code duplication. Indeed, the extra function adds another
> point of code flow redirection. On the other hand, it implicitly points
> out that basically the same is done for both rings.
>
> In my point of view, both ways are equally acceptable. If you prefer the
> other one for mainline inclusion, just let me know and I submit an
> appropriate patch.

Yes, that'd be good, thanks.
