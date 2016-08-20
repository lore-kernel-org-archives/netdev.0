From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 4/5] driver core: set up ownership of class devices in
 sysfs
Date: Fri, 19 Aug 2016 19:26:52 -0700
Message-ID: <20160819192652.369f123e@xeon-e3>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
        <1471386795-32918-5-git-send-email-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-5-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Aug 2016 15:33:14 -0700
Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:

>  static struct kobj_type device_ktype = {
>  	.release	= device_release,
>  	.sysfs_ops	= &dev_sysfs_ops,
>  	.namespace	= device_namespace,
> +	.get_ownership	= device_get_ownership,
>  };
>  

OT - I wonder if kobj_type could be ro_after_init?
