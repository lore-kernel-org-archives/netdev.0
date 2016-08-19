From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Make /sys/class/net per net namespace objects
 belong to container
Date: Fri, 19 Aug 2016 16:59:17 -0700 (PDT)
Message-ID: <20160819.165917.2302741905893802825.davem@davemloft.net>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, ebiederm@xmission.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: dmitry.torokhov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Tue, 16 Aug 2016 15:33:10 -0700

> There are objects in /sys hierarchy (/sys/class/net/) that logically belong
> to a namespace/container. Unfortunately all sysfs objects start their life
> belonging to global root, and while we could change ownership manually,
> keeping tracks of all objects that come and go is cumbersome. It would
> be better if kernel created them using correct uid/gid from the beginning.
> 
> This series changes kernfs to allow creating object's with arbitrary
> uid/gid, adds get_ownership() callback to ktype structure so subsystems
> could supply their own logic (likely tied to namespace support) for
> determining ownership of kobjects, and adjusts sysfs code to make use of
> this information. Lastly net-sysfs is adjusted to make sure that objects in
> net namespace are owned by the root user from the owning user namespace.
> 
> Note that we do not adjust ownership of objects moved into a new namespace
> (as when moving a network device into a container) as userspace can easily
> do it.

I need some domain experts to review this series please.

Thank you.
