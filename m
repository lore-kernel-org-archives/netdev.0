From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: power down phy when interface is down
Date: Wed, 19 Sep 2007 22:17:31 -0400
Message-ID: <46F1D83B.5070100@nvidia.com>
References: <e6c711510709180958j41265e87kd5126b7d5e832c0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ed Swierk <eswierk@arastra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:4644 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXITXm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 19:42:28 -0400
In-Reply-To: <e6c711510709180958j41265e87kd5126b7d5e832c0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that you are powering down the phy even if WOL is enabled.

Secondly, can you powerdown the phy at the same time you start 
performing autoneg restart?


Ed Swierk wrote:
> Bring the physical link down when the interface is down, by placing
> the PHY in power-down state. This mirrors the behavior of other
> drivers including e1000 and tg3.
> 
> Signed-off-by: Ed Swierk <eswierk@arastra.com>
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
