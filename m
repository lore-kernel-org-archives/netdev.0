From: Florian Westphal <fw@strlen.de>
Subject: Re: [lkp-robot] [test_rhashtable]  c1bd3689a7:
 WARNING:at_lib/debugobjects.c:#__debug_object_init
Date: Wed, 20 Sep 2017 10:44:28 +0200
Message-ID: <20170920084428.GA15946@breakpoint.cc>
References: <20170918210711.10202-5-fw@strlen.de>
 <20170920015457.GA30213@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lkp@01.org
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:59358 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751095AbdITIru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 04:47:50 -0400
Content-Disposition: inline
In-Reply-To: <20170920015457.GA30213@yexl-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel test robot <xiaolong.ye@intel.com> wrote:
> FYI, we noticed the following commit:
> 
> commit: c1bd3689a70d1ba1a2f7c6781770920087166018 ("test_rhashtable: add test case for rhl_table interface")
> url: https://github.com/0day-ci/linux/commits/Florian-Westphal/test_rhashtable-add-test-case-for-rhl-table/20170919-135550
> 
> 
> in testcase: boot
> 
> on test machine: qemu-system-x86_64 -enable-kvm -smp 2 -m 512M
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +---------------------------------------------------------+------------+------------+
> [   15.235031] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:328 __debug_object_init+0x794/0x930
[..]

This is with v1 of the patch where the rhltable struct was allocated on
stack, v2 is fine.
