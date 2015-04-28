From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] mlx4: Fix tx ring affinity_mask creation
Date: Tue, 28 Apr 2015 21:24:01 +0300
Message-ID: <CAJ3xEMiGSsDPNe+bFQxB-YshaDKjMCrgfqJW41MZ3-yKjefCRQ@mail.gmail.com>
References: <1428683240-22879-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428683240-22879-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 7:27 PM, Benjamin Poirier <bpoirier@suse.de> wrote:
> By default, the number of tx queues is limited by the number of online cpus in
> mlx4_en_get_profile(). However, this limit no longer holds after the ethtool
> .set_channels method has been called. In that situation, the driver may access
> invalid bits of certain cpumask variables when queue_index > nr_cpu_ids.
>

Hi Benjamin,

Can this fix be related to a specific commit? if yes, would be good if
you can add here a Fixes: line so it would be easier to spot down to
which stable kernels the fix should go.

Or.

> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
