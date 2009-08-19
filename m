From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] sky2: no recycling
Date: Wed, 19 Aug 2009 12:58:25 -0700
Message-ID: <20090819125825.0cf27e0e@s6510>
References: <20090819011704.685802801@vyatta.com>
	<20090819011738.993523293@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57196 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbZHST63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 15:58:29 -0400
In-Reply-To: <20090819011738.993523293@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2009 18:17:10 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> Recycling turns out to be a bad idea!  For most use cases, the
> packet can not be reused: TCP packets are cloned. Even for the ideal
> case of forwarding, it hurts performance because of CPU ping/pong.
> On a multi-core system forwarding of 64 byte packets is worse
> much worse: recycling = 24% forwarded vs no recycling = 42% forwarded

Minor correction on numbers.  The actual data for unidirectional
forwarding is 30% vs 24%. Previous data had hardware flow/control enabled
which skewed the numbers.
