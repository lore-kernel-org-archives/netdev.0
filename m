From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2 0/2] sctp: fix src address selection if using secondary
 address
Date: Mon, 20 Jul 2015 09:25:09 -0400
Message-ID: <55ACF6B5.9090107@gmail.com>
References: <cover.1437145508.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34336 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbGTNZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 09:25:12 -0400
In-Reply-To: <cover.1437145508.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2015 11:34 AM, Marcelo Ricardo Leitner wrote:
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

For the series:

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

>  net/sctp/protocol.c | 42 +++++++++++++++++++++++++++---------------
>  1 file changed, 27 insertions(+), 15 deletions(-)
> 
