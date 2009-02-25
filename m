From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 23/26] RDS: Add AF and PF #defines for RDS
	sockets
Date: Tue, 24 Feb 2009 23:26:48 -0800 (PST)
Message-ID: <20090224.232648.84203571.davem@davemloft.net>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<1235525443-9007-24-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: andy.grover@oracle.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1235525443-9007-24-git-send-email-andy.grover@oracle.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Andy Grover <andy.grover@oracle.com>
Date: Tue, 24 Feb 2009 17:30:40 -0800

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

Pick an unused number, you don't have to increment AF_MAX
to allocate a value.

And I don't want to hear any whining about how you've
used this value of 36 internally for a long time or
anything like that.
