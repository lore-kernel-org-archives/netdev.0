From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 21/21] RDS: Add AF and PF #defines for RDS sockets
Date: Tue, 27 Jan 2009 09:27:51 +0200
Message-ID: <200901270927.51855.remi.denis-courmont@nokia.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <1233022678-9259-22-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "ext Andy Grover" <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:24224 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbZA0H2I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:28:08 -0500
In-Reply-To: <1233022678-9259-22-git-send-email-andy.grover@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 January 2009 04:17:58 ext Andy Grover, you wrote:
> RDS is a reliable datagram protocol used for IPC on Oracle
> database clusters. This adds address and protocol family numbers
> for it.
>
> Signed-off-by: Andy Grover <andy.grover@oracle.com>
> ---
>  include/linux/socket.h |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 20fc4bb..fda91af 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -191,7 +191,8 @@ struct ucred {
>  #define AF_RXRPC	33	/* RxRPC sockets 		*/
>  #define AF_ISDN		34	/* mISDN sockets 		*/
>  #define AF_PHONET	35	/* Phonet sockets		*/
> -#define AF_MAX		36	/* For now.. */
> +#define AF_RDS		36	/* RDS sockets 			*/
> +#define AF_MAX		37	/* For now.. */
>
>  /* Protocol families, same as address families. */
>  #define PF_UNSPEC	AF_UNSPEC
> @@ -229,6 +230,7 @@ struct ucred {
>  #define PF_RXRPC	AF_RXRPC
>  #define PF_ISDN		AF_ISDN
>  #define PF_PHONET	AF_PHONET
> +#define PF_RDS		AF_RDS
>  #define PF_MAX		AF_MAX
>
>  /* Maximum queue length specifiable by listen.  */

You also need to add lock class declaration to net/core/sock.c, I belie=
ve.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

