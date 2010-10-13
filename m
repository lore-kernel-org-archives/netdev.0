From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH V2] Phonet: 'connect' socket implementation for Pipe controller
Date: Wed, 13 Oct 2010 09:18:51 +0200
Message-ID: <ec51036a9c6fbbb550fa5ef7ae7f13e3@chewa.net>
References: <1286950483-18804-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, davem@davemloft.net,
	netdev@vger.kernel.org, linus.walleij@stericsson.com,
	gulshan.karmani@stericsson.com, sudeep.divakaran@stericssonc.com
To: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38667 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab0JMHSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 03:18:53 -0400
In-Reply-To: <1286950483-18804-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 13 Oct 2010 11:44:43 +0530, Kumar A Sanghvi=0D
<kumar.sanghvi@stericsson.com> wrote:=0D
> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>=0D
> =0D
> Based on suggestion by R=C3=A9mi Denis-Courmont to implement 'connect=
'=0D
> for Pipe controller logic,  this patch implements 'connect' socket=0D
> call for the Pipe controller logic.=0D
> The patch does following:-=0D
> - Removes setsockopts for PNPIPE_CREATE and PNPIPE_DESTROY=0D
> - Adds setsockopt for setting the Pipe handle value=0D
> - Implements connect socket call=0D
> - Updates the Pipe controller logic=0D
> =0D
> User-space should now follow below sequence with Pipe controller:-=0D
> -socket=0D
> -bind=0D
> -setsockopt for PNPIPE_PIPE_HANDLE=0D
> -connect=0D
> -setsockopt for PNPIPE_ENCAP_IP=0D
> -setsockopt for PNPIPE_ENABLE=0D
> =0D
> GPRS/3G data has been tested working fine with this.=0D
> =0D
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>=0D
=0D
Acked-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

