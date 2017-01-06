From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv1 5/7] TAP: Extending tap device create/destroy APIs
Date: Fri, 06 Jan 2017 15:15:59 -0800
Message-ID: <1483744559.9712.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com>
         <1483742009-19184-6-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483742009-19184-6-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-06 at 14:33 -0800, Sainath Grandhi wrote:

> +static int tap_list_add(dev_t major, const char *device_name)
> +{
> +	int err = 0;
> +	struct major_info *tap_major;
> +
> +	tap_major = kzalloc(sizeof(*tap_major), GFP_ATOMIC);
> +
> +	tap_major->major = MAJOR(major);
> +


kzalloc() can perfectly return NULL.

You do not want to crash it that happens.
