From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] 100GbE Intel Wired LAN Driver
 Updates 2017-10-02
Date: Mon, 02 Oct 2017 11:59:55 -0700 (PDT)
Message-ID: <20171002.115955.389980093124095786.davem@davemloft.net>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdJBS76 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:59:58 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  2 Oct 2017 08:42:23 -0700

> This series contains updates to fm10k only.
> 
> Jake provides all but one of the changes in this series.  Most are small
> fixes, starting with ensuring prompt transmission of messages queued up
> after each VF message is received and handled.  Fix a possible race
> condition between the watchdog task and the processing of mailbox
> messages by just checking whether the mailbox is still open.  Fix a
> couple of GCC v7 warnings, including misspelled "fall through" comments
> and warnings about possible truncation of calls to snprintf().  Cleaned
> up a convoluted bitshift and read for the PFVFLRE register.  Fixed a
> potential divide by zero when finding the proper r_idx.
> 
> Markus Elfring fixes an issue which was found using Coccinelle, where
> we should have been using seq_putc() instead of seq_puts().
> 
> The following are changes since commit 0929567a7a2dab8455a7313956973ff0d339709a:
>   samples/bpf: fix warnings in xdp_monitor_user
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Pulled, thanks Jeff.
