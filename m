From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Wed, 8 Feb 2017 08:39:13 -0800
Message-ID: <589B49B1.4070304@gmail.com>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
 <20170207053455-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35532 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbdBHQlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:41:01 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so15612340pge.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:39:27 -0800 (PST)
In-Reply-To: <20170207053455-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> However, I came up with a new idea for the future and I'd like to show
> where I'm going.  The idea is that we don't use s/g buffers on RX, so we
> have a pointer per descriptor untapped.  So we can allow users to stick
> their own pointer in there, if they promise not to use s/g on this vq.
> With a full extra pointer to play with, we can go wild.

I looked at this quickly it seems like it would work and allow us to avoid
the reset. However, it seems like a lot of churn to avoid a single reset.
I don't see the reset itself as being that bad of an operation. I agree the
reset is not ideal though.

Are there any other use cases for this other than XDP?

> 
> Take a look but it doesn't even build yet.
> Need to roll it out to all devices etc.
> 
> --->
> 

[...]
