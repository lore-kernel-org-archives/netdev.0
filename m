From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] ks8851 DT updates
Date: Fri, 23 May 2014 15:37:36 -0400 (EDT)
Message-ID: <20140523.153736.705710213824474686.davem@davemloft.net>
References: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
	<20140523.151502.1106354754894891974.davem@davemloft.net>
	<537FA2A9.6050309@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org, nm@ti.com
To: sboyd@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEWThj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:37:39 -0400
In-Reply-To: <537FA2A9.6050309@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Fri, 23 May 2014 12:34:01 -0700

> On 05/23/14 12:15, David Miller wrote:
>> From: Stephen Boyd <sboyd@codeaurora.org>
>> Date: Thu, 22 May 2014 14:00:08 -0700
>>
>>> This set of patches properly documents the micrel ks8851 spi ethernet
>>> controller, converts to devm_regulator_get_optional() to make error
>>> paths slightly simpler, and finally adds supports for another
>>> optional regulator and a reset gpio.
>> Please do not submit patch sets that you expect different trees to
>> integrate, this is painful for maintainers to deal with.
>>
>> Instead, submit the changes separately.  One series for one
>> maintainer's tree, another for the other maintainer's tree.
>>
> 
> Ok. Shall I resend this series with the proper separation? Or can you
> ignore the first patch? There isn't any functional dependency, more just
> a checkpatch dependency which is not really all that important.

To avoid all ambiguity please resubmit the new series.
