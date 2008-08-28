From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [NET_NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Thu, 28 Aug 2008 09:12:50 -0700
Message-ID: <5f2db9d90808280912y63540c46mf57a8fe4a9ad1de1@mail.gmail.com>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080828.012719.114699916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:39403 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbYH1QMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 12:12:54 -0400
Received: by gxk9 with SMTP id 9so4751141gxk.13
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 09:12:53 -0700 (PDT)
In-Reply-To: <20080828.012719.114699916.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 28, 2008 at 1:27 AM, David Miller <davem@davemloft.net> wrote:

> I think you'll need to do range checking on the queue mapping being
> set in tcf_skbedit().
>
> qdisc_restart() will accept any skb_queue_mapping() value it
> sees in packets obtained via ->dequeue().
>

Noted.  I'll change this so that the action only occurs if
queue_mapping is less than skb->dev->real_num_tx_queues.

Thanks,

Alex
