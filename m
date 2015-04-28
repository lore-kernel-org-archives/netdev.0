From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option
 is set
Date: Tue, 28 Apr 2015 11:05:03 +0200
Message-ID: <553F4D3F.7000301@redhat.com>
References: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>,<20150427.134323.156569796484222010.davem@davemloft.net> <B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbbD1JFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:05:10 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2015 08:15 PM, Yuval Mintz wrote:
> I agree that this fixes an incorrect logic, but its incomplete as the bnx2x
> 'bp->flags' no longer represent the correct logic. I.e., it might cause
> additional issues down the road, as the 'fp->mode' and 'fp->disable_tpa'
> are no longer in sync.

> We already have a fix for this issue, we just haven't sent it to 'net'
> yet. Are you willing to give us an additional day to send an
> alternative fix?  Or do you prefer to take this, and possibly later
> we'll remove the logic added by this patch in our own?

Yuval,

I also have a patch that removes fp->disable_tpa by merging it into
fp->mode (adding a 3rd mode: TPA_MODE_DISABLED). And another patch that
removes {TPA,GRO}_ENABLE_FLAG by using dev->features everywhere.
I'll wait and see what changes you have.

Regards,
Michal
