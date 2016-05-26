From: Timur Tabi <timur@codeaurora.org>
Subject: Re: How can I test ndo_tx_timeout()?
Date: Thu, 26 May 2016 17:33:32 -0500
Message-ID: <574779BC.1020008@codeaurora.org>
References: <CAOZdJXWDp1VzCtu0PQp9m_62_2sXLZeiZqsmqb_GP71Bn1bMuQ@mail.gmail.com>
 <57476BC8.5060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56011 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbcEZWdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 18:33:36 -0400
In-Reply-To: <57476BC8.5060706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> One way to do this could be to never reclaim the SKBs you just
> transmitted which could be achieved by disabling the TX completion
> interrupt permanently for instance.

Thanks, that was the the trick.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
