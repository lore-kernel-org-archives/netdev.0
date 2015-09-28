From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 0/2] sctp: Fix SCTP deadlock
Date: Mon, 28 Sep 2015 06:35:17 -0400
Message-ID: <20150928103517.GA5248@hmsreliant.think-freely.org>
References: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52860 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245AbbI1Kfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 06:35:32 -0400
Content-Disposition: inline
In-Reply-To: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 12:15:05PM -0400, Karl Heiss wrote:
> These patches fix a deadlock during accept() of an SCTP connection.
> 
> The first patch fixes whitespace issues.
> 
> The second patch actually fixes the deadlock race.
> 
> Karl Heiss (2):
>   sctp: Whitespace fix
>   sctp: Prevent soft lockup when sctp_accept() is called during a
>     timeout event
> 
>  net/sctp/sm_sideeffect.c |   44 ++++++++++++++++++++++++--------------------
>  1 files changed, 24 insertions(+), 20 deletions(-)
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
