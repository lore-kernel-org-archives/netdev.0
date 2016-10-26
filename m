From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] netlink: Add nla_memdup() to wrap kmemdup() use
 on nlattr
Date: Wed, 26 Oct 2016 11:52:38 +0200
Message-ID: <20161026095238.GB16590@pox.localdomain>
References: <2d0864c85200f1b42b1ebceee7c2dc60fe29f26a.1477471562.git.tgraf@suug.ch>
 <1477472376.4059.23.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35329 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752681AbcJZJwl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 05:52:41 -0400
Received: by mail-wm0-f54.google.com with SMTP id e69so16292752wmg.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 02:52:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1477472376.4059.23.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/16 at 10:59am, Johannes Berg wrote:
> 
> >  /**
> > + * nla_memdup - duplicate attribute memory (kmemdup)
> > + * @src: netlink attribute to duplicate from
> > + * @gfp: GFP mask
> 
> Actually, is there any point in passing a GFP mask? None of the current
> users need it, and it seems fairly unlikely to be needed since this is
> typically used on the netlink input path, where you surely shouldn't
> need GFP_ATOMIC or so?

I'm fine either way. I didn't want to make assumptions which need
later changes. It's not hurting either and the function prototype
is very small.
