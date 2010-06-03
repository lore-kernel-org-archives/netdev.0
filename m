From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next PATCH] drivers/net/enic: Use (pr|netdev)_<level> macro
 helpers
Date: Thu, 03 Jun 2010 00:19:53 -0700
Message-ID: <C82CA5A9.3677A%scofeldm@cisco.com>
References: <1275492616.2489.20.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275492616.2489.20.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/2/10 8:30 AM, "Joe Perches" <joe@perches.com> wrote:

> Compile tested only
> 
> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove #define PFX
> Use pr_<level>
> Use netdev_<level>
> Remove trailing periods from most formats
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks Joe.  I tested it and there are a couple places before the netdev is
registered where we need dev_<level> rather than netdev_<level>, otherwise
we get output like:

enic 0000:08:00.0: (unregistered net_device): vNIC MAC addr
00:25:b5:19:35:8f wq/rq 256/512

I like the dev_name(dev) in there but not the "(unregister net_device)".

Also there where a couple of lines longer than 80 chars.

We can fix up the patch and resubmit if you like.

-scott
