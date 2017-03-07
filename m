From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 0/5] NAPI support for Hyper-V
Date: Mon, 6 Mar 2017 17:18:36 -0800
Message-ID: <20170306171836.5240a9b5@xeon-e3>
References: <20170227182651.3956-1-sthemmin@microsoft.com>
        <20170306.171333.1067660469641044496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34730 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932502AbdCGB1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:27:52 -0500
Received: by mail-pg0-f41.google.com with SMTP id 77so28207296pgc.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 17:27:51 -0800 (PST)
In-Reply-To: <20170306.171333.1067660469641044496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Mar 2017 17:13:33 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 27 Feb 2017 10:26:46 -0800
> 
> > These patches enable NAPI, GRO and napi_alloc_skb for Hyper-V netvsc
> > driver.  
> 
> Series applied to net-next.

Great, but how do we coordinate allow use of the vmbus iterator functions
for storage?  The way things are going that would mean waiting until 4.13 for
that.
