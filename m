From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 03/13] net-caif: add CAIF generic protocol
 stack header files
Date: Thu, 21 Jan 2010 09:13:10 +0100
Message-ID: <4B580C96.1040509@trash.net>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54114 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab0AUINP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 03:13:15 -0500
In-Reply-To: <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> +++ b/include/net/caif/generic/cfglue.h
> @@ -0,0 +1,110 @@
> +/*
> + * This file contains the OS and HW dependencies for CAIF.

This file looks like it should go away completely.


> +#endif /* CFGLUE_H_ */
> diff --git a/include/net/caif/generic/cflst.h b/include/net/caif/generic/cflst.h
> new file mode 100644
> index 0000000..6ff7168
> --- /dev/null
> +++ b/include/net/caif/generic/cflst.h
> @@ -0,0 +1,19 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2010
> + * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#ifndef CFLST_H_
> +#define CFLST_H_
> +
> +#include <net/caif/generic/cfglue.h>
> +
> +int cflst_put(struct layer **lst, uint8 id, struct layer *node);
> +struct layer *cflst_get(struct layer **lst, uint8 id);
> +struct layer *cflst_del(struct layer **lst, uint8 id);
> +#define CFLST_FIRST(lst) lst
> +#define CFLST_MORE(node) ((node) != NULL)
> +#define CFLST_NEXT(node) ((node)->next)
> +void cflst_init(struct layer **lst);
> +#endif	/* CFLST_H_ */

Why are you not using the list.h functions?
