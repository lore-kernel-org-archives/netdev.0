From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Wed, 3 Dec 2014 19:11:26 +0200
Message-ID: <20141203171126.GA7381@angus-think.wlc.globallogic.com>
References: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
 <20141203091338.2d32de2c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:32891 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaLCRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:21:10 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so20465370wgg.7
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:21:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141203091338.2d32de2c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2014 at 09:13:38AM -0800, Stephen Hemminger wrote:
> I don't see how you could get into accept_msg and cause this.
> 
> The filtering should already be done by kernel for most things.
> The code already filters TC messages in kernel. Other types
> should be done as well.

I think it was caused by RTM_NEWNDUSEROPT which was sent by router.
So in this case the message will be skipped with printed timestamp.

> Ps: this code is crying to be a switch statement.

I agree.
