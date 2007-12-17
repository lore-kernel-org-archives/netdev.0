From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 17 Dec 2007 17:27:11 +0100
Message-ID: <3ae72650712170827o21ea5e25v83490b2e73df2aa@mail.gmail.com>
References: <11979038181687@2ka.mipt.ru> <11979038192980@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763086AbXLQQ11@vger.kernel.org>
In-Reply-To: <11979038192980@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dec 17, 2007 4:03 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> +++ b/Documentation/dst/sysfs.txt
> @@ -0,0 +1,33 @@
> +This file describes sysfs files created for each storage.
> +
> +1. Per-storage files.
> +Each storage has its own dir /sysfs/devices/$storage_name,

> +2. Per-node files.
> +Node's files are located in /sysfs/devices/$storage_name/n-$start-$cookie

As already pointed out last time, you can't reference /sys/devices/ directly,
please use the path from the bus/class directory which points there.

Thanks,
Kay
