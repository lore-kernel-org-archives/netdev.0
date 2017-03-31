From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] virtio: allow drivers to validate features
Date: Fri, 31 Mar 2017 06:27:04 +0300
Message-ID: <20170331062634-mutt-send-email-mst@kernel.org>
References: <1490807652-27889-1-git-send-email-mst@redhat.com>
 <20170330.123931.210255819001973026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932873AbdCaD1H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 23:27:07 -0400
Content-Disposition: inline
In-Reply-To: <20170330.123931.210255819001973026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 12:39:31PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 29 Mar 2017 20:14:44 +0300
> 
> > Some drivers can't support all features in all configurations.  At the
> > moment we blindly set FEATURES_OK and later FAILED.  Support this better
> > by adding a callback drivers can use to do some early checks.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Michael do you want me to take these virtio networking fixes into my
> tree directly or are you going to send me a pull request or something
> after it all settles down?
> 
> Thanks.

I think I'll send a pull request.

Thanks,

-- 
MST
