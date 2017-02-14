From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/4] ptp: use is_visible method to hide unused attributes
Date: Tue, 14 Feb 2017 09:42:26 +0100
Message-ID: <20170214084226.GC8048@localhost.localdomain>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
 <20170214035108.19622-3-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214035108.19622-3-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 07:51:07PM -0800, Dmitry Torokhov wrote:
> Instead of creating selected attributes after the device is created (and
> after userspace potentially seen uevent), lets use attribute group
> is_visible() method to control which attributes are shown. This will allow
> us to create all attributes (except "pins" group, which will be taken care
> of later) before userspace gets notified about new ptp class device.

At first glance, this patch and the next look like nice improvements.
I don't futz around with sysfs code very often, and so may I ask how
or whether you tested it?

Thanks,
Richard
