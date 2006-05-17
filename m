From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2/4] myri10ge - Driver header files
Date: Wed, 17 May 2006 15:28:17 -0700
Message-ID: <20060517152817.58a6d8bc.rdunlap@xenotime.net>
References: <20060517220218.GA13411@myri.com>
	<20060517220434.GC13411@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:35238 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751254AbWEQWZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 18:25:51 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 17 May 2006 15:25:47 -0700
To: Brice Goglin <brice@myri.com>
In-Reply-To: <20060517220434.GC13411@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 May 2006 18:04:35 -0400 Brice Goglin wrote:

> [PATCH 2/4] myri10ge - Driver header files
> 
>  myri10ge_mcp.h            |  205 ++++++++++++++++++++++++++++++++++++++++++++++
>  myri10ge_mcp_gen_header.h |   58 +++++++++++++

Please use "diffstat -p 1 -w 70" is documented in
Documentation/SubmittingPatches.

>  2 files changed, 263 insertions(+)
> 
> --- /dev/null	2006-05-16 20:08:50.920483500 +0200
> +++ linux-tmp//drivers/net/myri10ge/myri10ge_mcp.h	2006-05-17 11:02:48.000000000 +0200
> @@ -0,0 +1,205 @@
> +#ifndef __MYRI10GE_MCP_H__
> +#define __MYRI10GE_MCP_H__
> +
> +#define MYRI10GE_MCP_VERSION_MAJOR	1
> +#define MYRI10GE_MCP_VERSION_MINOR	4
> +
> +/* 16 Bytes */

What is 16 bytes here?

> +struct mcp_slot {
> +	u16 checksum;
> +	u16 length;
> +};


---
~Randy
