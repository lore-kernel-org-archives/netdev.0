From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Fri, 27 Jan 2017 07:34:38 +0200
Message-ID: <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34290 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753487AbdA0Fmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 00:42:40 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so29889990otj.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 21:42:40 -0800 (PST)
In-Reply-To: <20170126233241.2268449-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
> Add a configuration option (CONFIG_MLX5_CORE_ESWITCH) for controlling
> whether the eswitch code is built. Change Kconfig and Makefile
> accordingly.

Tom, FWIW, please note that the basic e-switch functionality is needed
also when SRIOV isn't of use, this is for a multi host configuration.

Or.

My WW (and same for the rest of the IL team..) has ended so I will be
able to further look on this series and comment on Sunday.
