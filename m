From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 01/13] net: ethernet: aquantia: Make and
 configuration files.
Date: Thu, 12 Jan 2017 09:15:29 -0500 (EST)
Message-ID: <20170112.091529.1076462152235819647.davem@davemloft.net>
References: <cover.1484192452.git.vomlehn@texas.net>
        <cover.1484192452.git.vomlehn@texas.net>
        <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vomlehn@texas.net,
        Simon.Edelhaus@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Pavel.Belous@aquantia.com, Dmitry.Bezrukov@aquantia.com
To: Alexander.Loktionov@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdALOPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:15:35 -0500
In-Reply-To: <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Date: Wed, 11 Jan 2017 19:53:05 -0800

> @@ -0,0 +1,19 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +
> +#ifndef VER_H
> +#define VER_H
> +
> +#define NIC_MAJOR_DRIVER_VERSION           1
> +#define NIC_MINOR_DRIVER_VERSION           5
> +#define NIC_BUILD_DRIVER_VERSION           339
> +#define NIC_REVISION_DRIVER_VERSION        0
> +
> +#endif /* VER_H */
> +

Please do not add empty lines at the end of files, GIT even warns
about this.

Please audit your entire submission for this problem.
