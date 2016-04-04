From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge:Fix incorrect variable assignment on error path
 in br_sysfs_addbr
Date: Mon, 04 Apr 2016 16:14:18 -0400 (EDT)
Message-ID: <20160404.161418.1551441547560943567.davem@davemloft.net>
References: <1459724666-3666-1-git-send-email-bastienphilbert@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bastienphilbert@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459724666-3666-1-git-send-email-bastienphilbert@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bastien Philbert <bastienphilbert@gmail.com>
Date: Sun,  3 Apr 2016 19:04:26 -0400

> This fixes the incorrect variable assignment on error path in
> br_sysfs_addbr for when the call to kobject_create_and_add
> fails to assign the value of -EINVAL to the returned variable of
> err rather then incorrectly return zero making callers think this
> function has succeededed due to the previous assignment being
> assigned zero when assigning it the successful return value of
> the call to sysfs_create_group which is zero.
> 
> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>

Applied, but please put a space after the subsystem prefix and the
colon character in your subject lines in the future.

Doesn't that really look odd to you, the way you did it? "net:Fix"?

Doesn't it look more natural, and consistent with what all other
patch submitters do, if it's "net: Fix"?

Thanks.
