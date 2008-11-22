From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 14/32] ixgbe section fixes
Date: Sat, 22 Nov 2008 11:43:17 -0800
Message-ID: <9929d2390811221143n66f3f09bu3801919a54263589@mail.gmail.com>
References: <E1L3wOM-0006Ti-Jt@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev <netdev@vger.kernel.org>
To: "Al Viro" <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:61865 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbYKVTnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 14:43:19 -0500
Received: by hs-out-0708.google.com with SMTP id 4so647994hsl.5
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2008 11:43:17 -0800 (PST)
In-Reply-To: <E1L3wOM-0006Ti-Jt@ZenIV.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2008 at 9:35 AM, Al Viro <viro@ftp.linux.org.uk> wrote:
>
> ixgbe_init_interrupt_scheme() is called from ixgbe_resume().  Build that
> with CONFIG_PM and without CONFIG_HOTPLUG and you've got a problem.
> Several helpers called by it also are misannotated __devinit.
>
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
>

Adding Netdev...

Patch does not apply to latest net-next-2.6 tree because half of the
requested changes are already applied to the driver in an earlier
commit.

Please re-test with
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
if possible.

-- 
Cheers,
Jeff
