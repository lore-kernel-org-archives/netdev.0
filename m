From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 0/2] sctp: Fix SCTP deadlock
Date: Fri, 25 Sep 2015 16:52:49 -0300
Message-ID: <20150925195249.GA3087@localhost.localdomain>
References: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932891AbbIYTww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 15:52:52 -0400
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

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
