From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] RDS: verify the underlying transport exists before
 creating a connection
Date: Fri, 4 Sep 2015 23:24:58 +0300
Message-ID: <55E9FE1A.4080103@cogentembedded.com>
References: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, chien.yen@oracle.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35545 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbbIDUZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 16:25:02 -0400
Received: by lbpo4 with SMTP id o4so17299739lbp.2
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 13:25:00 -0700 (PDT)
In-Reply-To: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/04/2015 07:43 PM, Sasha Levin wrote:

> There was no verification that an underlying transport exists when creating
> a connection, this would cause dereferencing a NULL ptr.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   net/rds/connection.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/net/rds/connection.c b/net/rds/connection.c
> index a50e652..0218d81 100644
> --- a/net/rds/connection.c
> +++ b/net/rds/connection.c
> @@ -189,6 +189,12 @@ new_conn:
>   		}
>   	}
>
> +	if (trans == NULL) {

   Please use !trans instead, it's the form preferred by the networking code.

[...]

MBR, Sergei
