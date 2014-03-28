From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 17:02:22 -0400 (EDT)
Message-ID: <20140328.170222.346040641241669437.davem@davemloft.net>
References: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
	<20140328.145410.1817326821928803131.davem@davemloft.net>
	<CANq1E4TxaNnZoqfw5DiifAhk28hVq5HJJMd07ZDFAjdc68nKKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teg@jklm.no, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: dh.herrmann@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4TxaNnZoqfw5DiifAhk28hVq5HJJMd07ZDFAjdc68nKKg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Herrmann <dh.herrmann@gmail.com>
Date: Fri, 28 Mar 2014 20:34:47 +0100

> However, as mentioned in the discussions on v1, there're more
> use-cases than that. Imagine a 3rd party initrd renames a
> network-device early, if udev runs in the main system, we would rename
> the device again. If we could detect the rename via NET_NAME_RENAMED,
> we wouldn't break such setups. The only reason to rename devices in
> udev is to get reliable names. If someone else already renamed a
> device, we always expect them to provide better names than we do, so
> udev should only touch devices that have kernel-enumerated names.
> Of course, this can be fixed by requiring all the initrd developers to
> somehow tag devices as already renamed. But this would replicate
> information that the kernel already has.

You want to use the kernel to facilitate communication between two
userland components.

Imagine if we had to do that for everything.

Really, it's not a good reason, sorry.
