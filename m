From: Chang <changxiangzhong@gmail.com>
Subject: Re: [PATCH] net: sctp: set chunk->tsn_gap_acked at the end of cycle
Date: Sat, 23 Nov 2013 12:14:12 +0100
Message-ID: <52908E04.40200@gmail.com>
References: <1385106589-402-1-git-send-email-changxiangzhong@gmail.com> <528F69B7.7020902@gmail.com> <528FAF50.10100@gmail.com> <528FDF52.4030500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33188 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3KWLOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 06:14:15 -0500
In-Reply-To: <528FDF52.4030500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Could you please why a **reneged** newly acked TSN doesn't qualify the 
highest_new_tsn? What's the wrongs of doing that?

I've been thinking a few scenarios, but I couldn't figure out what's 
wrong with that.
