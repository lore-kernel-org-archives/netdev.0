From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] store complete hash type information in socket
 buffer...
Date: Wed, 17 Feb 2016 22:30:01 +0100
Message-ID: <1455744601.648.2.camel@edumazet-ThinkPad-T530>
References: <1455525128-27795-1-git-send-email-paul.durrant@citrix.com>
	 <20160217.154432.788293606088459412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, netdev@vger.kernel.org,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34908 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423542AbcBQVaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:30:12 -0500
Received: by mail-wm0-f51.google.com with SMTP id c200so234990615wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 13:30:11 -0800 (PST)
In-Reply-To: <20160217.154432.788293606088459412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mer., 2016-02-17 at 15:44 -0500, David Miller wrote:
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Mon, 15 Feb 2016 08:32:08 +0000
> 
> > ...rather than a boolean merely indicating a canonical L4 hash.
> > 
> > skb_set_hash() takes a hash type (from enum pkt_hash_types) as an
> > argument but information is lost since only a single bit in the skb
> > stores whether that hash type is PKT_HASH_TYPE_L4 or not. By using
> > two bits it's possible to store the complete hash type information.
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> Tom and/or Eric, please have a look at this.

I guess my question is simply 'why do we need this' ?

Consuming a bit in our precious sk_buff is not something we want for
some obscure feature.
