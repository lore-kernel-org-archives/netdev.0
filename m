From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 0/2] rocker: unused parameter and const
 cleanups
Date: Thu, 14 May 2015 18:31:09 +0900
Message-ID: <20150514093106.GA2139@penelope.isobedori.kobe.vergenet.net>
References: <1431574976-18214-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34615 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbbENJbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 05:31:20 -0400
Received: by pacyx8 with SMTP id yx8so79567100pac.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 02:31:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431574976-18214-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 12:42:54PM +0900, Simon Horman wrote:
> This series provides some minor though verbose cleanup of rocker.
> 
> The second patch depends on the first though it could be rebased.
> 
> * Changes v1 -> v2
>   - Found quite a few more variables and parameters to make const
> 
> Simon Horman (2):
>   rocker: remove unused rocker_port parameter from rocker_port_kfree
>   rocker: mark parameters and local variables as const
> 
>  drivers/net/ethernet/rocker/rocker.c | 454 ++++++++++++++++++-----------------
>  1 file changed, 232 insertions(+), 222 deletions(-)

As per my response to "[PATCH net-next v7 00/24] switchdev: spring cleanup"
I am seeing some problems with this patch set applied. I'm not sure
that it is related, but to be safe, please hold off on this for now.
