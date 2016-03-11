From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 11:09:27 -0800
Message-ID: <20160311110927.5c559421@xeon-e3>
References: <20160311182949.GG3383@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34889 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcCKTJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:09:17 -0500
Received: by mail-pa0-f48.google.com with SMTP id td3so79560805pab.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 11:09:16 -0800 (PST)
In-Reply-To: <20160311182949.GG3383@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Mar 2016 13:29:49 -0500
Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

>  
> -#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
> +static int sndbuf_size = 16384;
> +module_param(sndbuf_size, int, 0444);
> +MODULE_PARM_DESC(sndbuf_size, "SO_SNDBUF size of kernel tcp socket");
> +
> +static int rcvbuf_size = 87380;
> +module_param(rcvbuf_size, int, 0444);
> +MODULE_PARM_DESC(rcvbuf_size, "SO_RCVBUF size of kernel tcp socket");

Module parameters are a problem for distributions and should only be used
as a last resort.
