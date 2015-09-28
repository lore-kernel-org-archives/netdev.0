From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 07/23] usb-gadget/f_loopback: use per-attribute show
	and store methods
Date: Mon, 28 Sep 2015 15:41:01 +0200
Message-ID: <20150928134101.GD30453@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de> <1443189000-13398-8-git-send-email-hch@lst.de> <560928B1.1000605@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560928B1.1000605@samsung.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 28, 2015 at 01:46:57PM +0200, Andrzej Pietrasiewicz wrote:
>>   }
>>
>> -static struct f_lb_opts_attribute f_lb_opts_qlen =
>> -	__CONFIGFS_ATTR(qlen, S_IRUGO | S_IWUSR,
>> -			f_lb_opts_qlen_show,
>> -			f_lb_opts_qlen_store);
>> -
> In my opinion the below line belongs here:
>
> +CONFIGFS_ATTR(f_lb_opts_, qlen);

The idea is to keep all the attribute defintions near the attribute
array, similar to how most drivers define their sysfs attributes.

If you really don't like that way I'll move it back.
