From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 14:16:01 +0100
Message-ID: <1378991761.1531.2.camel@bwh-desktop.uk.level5networks.com>
References: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
	 <20130912.012443.2294235053428746280.davem@davemloft.net>
	 <000601ceaf7b$e8e7b2e0$bab718a0$%han@samsung.com>
	 <20130912.033606.1689936899104585741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jg1.han@samsung.com>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57200 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab3ILPxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:53:39 -0400
In-Reply-To: <20130912.033606.1689936899104585741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 03:36 -0400, David Miller wrote:
> From: Jingoo Han <jg1.han@samsung.com>
> Date: Thu, 12 Sep 2013 14:49:56 +0900
> 
> > On Thursday, September 12, 2013 2:25 PM, David Miller wrote:
> >> On Thu, 12 Sep 2013 09:11:01 +0900, Jingoo Han wrote:
> >> > Would you let know the reason not to add coding style fixes?
> >> 
> >> They should be made seperately so that the individual changes
> >> can be reviewed more easily and without unnecessary unrelated
> >> changes mixed in.
> > 
> > OK, I see. :-)
> > Thank you for your answer.
> > Then, I will send V2 patch soon.
> 
> Please do not submit such a huge patch series in the future.
> 
> Anything more than 16 patches at a time is not reasonable and
> overloads reviewer's capacity to look at your changes.

Given that this is the same trivial change applied to many different
drivers, is it really worthwhile to break it up into a patch per driver?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
