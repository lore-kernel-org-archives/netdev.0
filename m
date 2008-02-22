From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix multicast on VLAN interfaces
Date: Fri, 22 Feb 2008 13:25:53 +0100
Message-ID: <47BEBF51.5020306@trash.net>
References: <20080221220542.GA19693@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50234 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739AbYBVM0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 07:26:17 -0500
In-Reply-To: <20080221220542.GA19693@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester wrote:
> In commit 56addd6eeeb4e11f5a0af7093ca078e0f29140e0 the VLAN multicast list
> handling was reworked.  Unfortunately, a variable initialization was missed,
> and multicast over vlan devices has been broken since 2.6.23-rc1 (apparently
> not too many people use this).  Trivial fix below, which might be a candidate
> for -stable.

Thanks Phil, a similar patch is already sitting in net-2.6.git.
