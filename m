From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH 1/2] net: socket.h structures documentation
Date: Sun, 03 Aug 2014 15:48:52 -0700
Message-ID: <53DEBC54.7020708@infradead.org>
References: <1406928683-4317-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Karoly Kemeny <karoly.kemeny@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59765 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbaHCWsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 18:48:55 -0400
In-Reply-To: <1406928683-4317-1-git-send-email-karoly.kemeny@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/14 14:31, Karoly Kemeny wrote:
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> ---
>  include/linux/socket.h | 78 ++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 57 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index ec538fc..18c225a 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h

> @@ -131,6 +163,10 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
>  #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
>  #define SCM_SECURITY	0x03		/* rw: security label		*/
>  
> +/**
> + *  struct ucred - credentials represented an a struct in the ancilliary message

                                              as

and then add:
Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> + */
> +
>  struct ucred {
>  	__u32	pid;
>  	__u32	uid;
> 


-- 
~Randy
