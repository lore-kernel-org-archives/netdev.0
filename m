From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 00/17] latest qdisc patch series
Date: Tue, 6 Jun 2017 07:30:15 +0300
Message-ID: <20170606072545-mutt-send-email-mst@kernel.org>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Jason Wang <jasowang@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750704AbdFFEaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 00:30:16 -0400
Content-Disposition: inline
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 08:36:03AM -0700, John Fastabend wrote:
> I am not going to be able to work on this for a few days so I figured
> it might be worth getting some feedback if there is any. Any thoughts
> on how to squeeze a few extra pps out of this would be very useful.

Batch dequeue into a temporary buffer, then scan this
buffer and xmit without locks might be a good idea.
It certainly helped vhost. You might need to requeue
if you are unable to xmit, there's now support for this.

-- 
MST
