From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 29/31] Constify struct sysfs_ops for 2.6.32 v1
Date: Mon, 7 Dec 2009 10:53:57 +0100
Message-ID: <20091207095356.GA3243@bluebox.local>
References: <4B198670.2000406@gmail.com> <4B1991E2.5010903@gmail.com> <4B19A33B.9050907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony.luck@intel.com, fenghua.yu@intel.com,
	benh@kernel.crashing.org, lethal@linux-sh.org, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, axboe@kernel.dk, gregkh@suse.de,
	petero2@telia.com, davej@redhat.com, maciej.sosnowski@intel.com,
	dougthompson@xmission.com, airlied@linux.ie, rolandd@cisco.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, neilb@suse.de,
	rdunlap@xenotime.net, kyle@mcmartin.ca, deller@gmx.de,
	jejb@parisc-linux.org, jbarnes@virtuousgeek.org, hjk@linutronix.de,
	david.vrabel@csr.com, jeremy@xensource.com, chris.mason@oracle.com,
	ccaulfie@redhat.com, teigland@redhat.com, tytso@mit.edu,
	adilger@sun.com, swhiteho@redhat.com, mfasheh@suse.com,
	joel.becker@oracle.com, rusty@rustcorp.com.au,
	penberg@cs.helsinki.fi, shemminger@linux-foundation.org,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934952AbZLGJ6W@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B19A33B.9050907@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 05, 2009 at 01:03:07AM +0100, Emese Revfy wrote:
> From: Emese Revfy <re.emese@gmail.com>
> 
> Constify struct sysfs_ops.
> Per Dave Miller's suggestion, resend with proper CC list and patch format.
> 
> Signed-off-by: Emese Revfy <re.emese@gmail.com>

For the Userspace I/O part:
Acked-by: Hans J. Koch <hjk@linutronix.de>

> ---

[...]

>  drivers/uio/uio.c                     |    4 ++--

[...]

> diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
> index e941367..4de382a 100644
> --- a/drivers/uio/uio.c
> +++ b/drivers/uio/uio.c
> @@ -129,7 +129,7 @@ static ssize_t map_type_show(struct kobject *kobj, struct attribute *attr,
>  	return entry->show(mem, buf);
>  }
>  
> -static struct sysfs_ops map_sysfs_ops = {
> +static const struct sysfs_ops map_sysfs_ops = {
>  	.show = map_type_show,
>  };
>  
> @@ -217,7 +217,7 @@ static ssize_t portio_type_show(struct kobject *kobj, struct attribute *attr,
>  	return entry->show(port, buf);
>  }
>  
> -static struct sysfs_ops portio_sysfs_ops = {
> +static const struct sysfs_ops portio_sysfs_ops = {
>  	.show = portio_type_show,
>  };
