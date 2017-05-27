From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Sun, 28 May 2017 00:02:13 +0300
Message-ID: <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
References: <20170526211624.23133-1-jsorensen@fb.com> <20170526211624.23133-8-jsorensen@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Jes Sorensen <jsorensen@fb.com>
To: Jes Sorensen <jes.sorensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35116 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdE0VCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 17:02:15 -0400
Received: by mail-oi0-f65.google.com with SMTP id v80so6638115oie.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 14:02:14 -0700 (PDT)
In-Reply-To: <20170526211624.23133-8-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 27, 2017 at 12:16 AM, Jes Sorensen <jes.sorensen@gmail.com> wrote:
> This gets rid of the temporary #ifdef spaghetti and allows the code to
> compile without offload support enabled.

Hi Jes,

I am pretty sure we can do that exercise you're up to without any
spaghetti cooking and even put more code under that CONFIG directive
(en_rep.c), I'll take that with Saeed.

Just wondering, you are motivated by a wish to put some mlx5
functionalities under their own CONFIG directives which could be
useful when backporting the latest upstream driver into older kernel
and being able not to deal with parts of it, right? in that respect,
are you using SRIOV but not the offloads mode?

Or.
