From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] sctp: fix src address selection if using
 secondary address
Date: Mon, 20 Jul 2015 10:43:02 -0400
Message-ID: <20150720144302.GB10706@hmsreliant.think-freely.org>
References: <cover.1437145508.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54583 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbbGTOnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 10:43:09 -0400
Content-Disposition: inline
In-Reply-To: <cover.1437145508.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 12:34:16PM -0300, Marcelo Ricardo Leitner wrote:
> This series improves the way SCTP chooses its src address so that the
> choosen one will always belong to the interface being used for output.
> 
> v1->v2:
>  - split out the refactoring from the fix itself
>  - Doing a full reverse routing as in v1 is not necessary. Only looking
>    for the interface that has the address and comparing its number is
>    enough.
> 
> Marcelo Ricardo Leitner (2):
>   sctp: reduce indent level on sctp_v4_get_dst
>   sctp: fix src address selection if using secondary addresses
> 
>  net/sctp/protocol.c | 42 +++++++++++++++++++++++++++---------------
>  1 file changed, 27 insertions(+), 15 deletions(-)
> 
> -- 
> 2.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
