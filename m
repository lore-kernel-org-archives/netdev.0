From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net 00/13] Mellanox 100G mlx5 resiliency and xmit path fixes
Date: Fri, 1 Jul 2016 14:22:10 +0300
Message-ID: <CALzJLG_u1B3PYzmzE0gLL7p0eXo9rTWfCP1kw8XE3gbA=Og+pQ@mail.gmail.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com> <20160701.061449.151195686797738506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36819 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbcGAL30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 07:29:26 -0400
Received: by mail-qk0-f173.google.com with SMTP id j2so141792581qkf.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 04:29:26 -0700 (PDT)
In-Reply-To: <20160701.061449.151195686797738506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 1:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Thu, 30 Jun 2016 17:34:37 +0300
>
>> This series provides two set of fixes to the mlx5 driver:
>>       - Resiliency fixes for reset flow and internal pci errors
>>       - xmit path fixes
>
> Series applied to 'net' but expecting all of this to be backported
> to -stable is unreasonable.
>
> PCI error paths, chip resets, timeout handling, etc. and some
> non-trivial changes.  This is not appropriate for -stable at all.
>
> What's relevant for -stable is operational bug fixes for issues
> users will hit in regular operation.
>
> And yes this is partially my own interpreation of what is appropriate
> for -stable.
>
> But if I were to set the precendence of adding all of these to -stable
> it means people will then be able to request similar things in other
> drivers.  We want to avoid having too much grey area stuff backported
> to -stable, there are too many changes going through -stable already.

Understood,

but some fixes are really really critical to us, so i would suggest
new list for -stable

net/mlx5: Avoid calling sleeping function by the health poll thread
net/mlx5: Fix wait_vital for VFs and remove fixed sleep
net/mlx5e: Copy all L2 headers into inline segment
net/mlx5e: Fix select queue callback

Thanks,
Saeed.
