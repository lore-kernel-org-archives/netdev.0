From: Allen <allen.lkml@gmail.com>
Subject: Re: [PATCH 05/10] drivers:net: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 18:35:58 +0530
Message-ID: <CAOMdWSKGuEBJPropUwveuP-Lr3NSAxdoNvCUWRGC_jWpNYQfFA@mail.gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
 <1505287939-14106-5-git-send-email-allen.lkml@gmail.com> <20170913120909.GA11820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
        linux-crypto@vger.kernel.org, dri-devel@lists.freedesktop.org,
        MPT-FusionLinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, megaraidlinux.pdl@broadcom.com,
        target-devel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-btrfs@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170913120909.GA11820@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> propagates the -1. That is only called by bond_open() with:
>
>         if (bond_alb_initialize(bond, (BOND_MODE(bond) == BOND_MODE_ALB)))
>                 return -ENOMEM;
>
> So you might want to also modify this code, to return the return
> value, rather than use the hard coded ENOMEM.
>

 I'll modify the above and send it out a separate patch.

Thank you.
