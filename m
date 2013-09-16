From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix VF reset recovery
Date: Mon, 16 Sep 2013 00:54:27 -0400 (EDT)
Message-ID: <20130916.005427.1555320731863092876.davem@davemloft.net>
References: <1379067227-10362-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab3IPEy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:54:28 -0400
In-Reply-To: <1379067227-10362-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Fri, 13 Sep 2013 06:13:47 -0400

> o At the time of firmware hang "adapter->need_fw_reset" variable gets
>   set but after re-initialization of firmware OR at the time of VF
>   re-initialization that variable was not getting cleared which
>   was leading to failure in VF reset recovery.Fix it by clearing
>   this variable before re-initializing VF
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied.
