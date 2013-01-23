From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: tun mq failure
Date: Wed, 23 Jan 2013 12:06:40 +0100
Message-ID: <20130123110640.GC7005@order.stressinduktion.org>
References: <20130123100516.GB8108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46096 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab3AWLGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 06:06:41 -0500
Content-Disposition: inline
In-Reply-To: <20130123100516.GB8108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 12:05:16PM +0200, Michael S. Tsirkin wrote:
> This is when trying to start a VPN using some old openvpn binary so MQ
> is not set.
> 
> So
> 1. I think we should limit allocation of MQ to when MQ flag is set in SETIFF.
> 2. order 7 allocation is 2^^7 pages - about half a megabyte of contigious
>    memory. This is quite likely to fail.
>    Let's start with a small limit on number of queues, like 8?
>    Then we know it will succeed.
>    Longer term we might want to solve it differently.

This has been come up before:
http://thread.gmane.org/gmane.linux.network/255647/focus=255902

I think a solution to this problem is still outstanding.
