From: David Miller <davem@davemloft.net>
Subject: Re: [net] Revert "e1000e: driver trying to free already-free irq"
Date: Fri, 24 Mar 2017 13:44:21 -0700 (PDT)
Message-ID: <20170324.134421.38038996156419101.davem@davemloft.net>
References: <20170324034715.72855-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965355AbdCXUoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:44:23 -0400
In-Reply-To: <20170324034715.72855-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Mar 2017 20:47:15 -0700

> This reverts commit 7e54d9d063fa239c95c21548c5267f0ef419ff56.
> 
> After additional regression testing, several users are experiencing
> kernel panics during shutdown on e1000e devices.  Reverting this
> change resolves the issue.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied and queued up for -stable.
