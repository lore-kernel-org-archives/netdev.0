From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 13:51:43 +0100
Message-ID: <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, "Greg KH" <greg@kroah.com>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11972872501664@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dec 10, 2007 12:47 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> diff --git a/Documentation/dst/sysfs.txt b/Documentation/dst/sysfs.txt
> new file mode 100644
> index 0000000..79d79dc
> --- /dev/null
> +++ b/Documentation/dst/sysfs.txt
> @@ -0,0 +1,30 @@
> +This file describes sysfs files created for each storage.
> +
> +1. Per-storage files.
> +Each storage has its own dir /sysfs/devices/$storage_name,

It's always /sys/devices/.

> +which contains following files:
> +
> +alg - contains name of the algorithm used to created given storage
> +name - name of the storage
> +nodes - map of the storage (list of nodes and their sizes and starts)
> +remove_all_nodes - writable file which allows to remove all nodes from given
> +       storage
> +n-$start-$cookie - per node directory, where
> +       $start - start of the given node in sectors,
> +       $cookie - unique node's id used by DST
> +
> +2. Per-node files.
> +Node's files are located in /sysfs/devices/$storage_name/n-$start-$cookie
> +directory, described above.

To which class or bus do the devices you create belong? Care to show a
"tree" or "ls -la" of the device?

Kay
