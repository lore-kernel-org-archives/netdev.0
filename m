From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 1/3] tun: ethtool stats
Date: Fri, 6 Oct 2017 16:12:45 -0700
Message-ID: <20171006161245.0f4abb99@xeon-e3>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
        <20171006222516.90654-2-willemdebruijn.kernel@gmail.com>
        <20171006153059.193688a5@xeon-e3>
        <CAF=yD-JZnJ4v3KZY2O3yBKWNnLxRBZJcJDVkYNuHYUZHX5Yw-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:54583 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdJFXMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:12:55 -0400
Received: by mail-pg0-f41.google.com with SMTP id c137so10629616pga.11
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 16:12:55 -0700 (PDT)
In-Reply-To: <CAF=yD-JZnJ4v3KZY2O3yBKWNnLxRBZJcJDVkYNuHYUZHX5Yw-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Oct 2017 18:37:01 -0400
Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:

> > It looks like you are just exporting the statistics taht are already
> > through normal path. The purpose of ethtool stats is to provide
> > statistics unique to the device, not to repeat what is available throug
> > ip, ifconfig, etc.  
> 
> A follow-up patch adds non-standard statistics.
> 
> I included these common ones, because the new zerocopy counters
> are only interesting in relation to tx_packets.
> 
> It also seems customary among existing network drivers to include
> at least these base counters in the ethtool output.

Only some drivers that slipped through before I started noticing.
Do Not Repeat.
