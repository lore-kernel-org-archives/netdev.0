From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 15:14:08 -0800
Message-ID: <1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	 <CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
	 <CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:64261 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbBRXOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 18:14:10 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so55106215iga.1
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 15:14:09 -0800 (PST)
In-Reply-To: <CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-18 at 14:11 -0800, Cong Wang wrote:
> On Wed, Feb 18, 2015 at 1:18 PM, Cong Wang <cwang@twopensource.com> wrote:
> >
> > 2) This breaks the queue mapping specified by an skbedit action,
> > since for TX queues the index starts with 0 while for RX it starts with 1
> > (for some reason I don't see yet). There is at least a mismatch.
> 
> So queue 0 is reserved for TX, at least for bonding queue mapping.

It seems you missed that bonding ndo_select_queue() is rather special.
