From: Nick H <nickkvm@gmail.com>
Subject: rxhash for virtio_net
Date: Thu, 22 Jan 2015 21:43:15 -0800
Message-ID: <CAMou0=wWLy+KMue79Afrf8SRkqsC9qB+p_GRUCWFzM7kNtvAfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mst@redhat.com, jasonwang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:46071 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbbAWFnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 00:43:16 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so5561172iec.6
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 21:43:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying to enable rxhash for virtio_net over net-next, I found
that we still do not support it. Quick Google search yields several
patches (including flow-director for virtio_net), but looks like none
of them made it in. If my observation is correct, what are the
prominent reasons why rxhash support for virtio has not made its way
in ? (I see some concerns over Out-of-order delivery etc, any other ?
). Without rxhash for virtio, is there a way to tie a flow to a
particular cpu on host and guest side ?

Thanks,
N
