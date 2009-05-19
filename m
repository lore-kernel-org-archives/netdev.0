From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix skb_seq_read returning wrong offset/length
 for page frag data
Date: Mon, 18 May 2009 21:44:23 -0700 (PDT)
Message-ID: <20090518.214423.64792089.davem@davemloft.net>
References: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shyam_Iyer@Dell.com, michaelc@cs.wisc.edu
To: Thomas_Chenault@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50267
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754604AbZESEoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 00:44:25 -0400
In-Reply-To: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Thomas_Chenault@Dell.com>
Date: Wed, 13 May 2009 20:33:11 -0500

> When called with a consumed value that is less than skb_headlen(skb)
> bytes into a page frag, skb_seq_read() incorrectly returns an
> offset/length relative to skb->data. Ensure that data which should come
> from a page frag does.
> 
> Signed-off-by: Thomas Chenault <thomas_chenault@dell.com>

Applied and queued up for -stable, thanks.

> @@ -2288,7 +2288,7 @@ unsigned int skb_seq_read(unsigned int consumed,
> const u8 **data,

Lots of lines in this patch were chopped up by your email client.
Please fix this up before you submit any future patches, thanks.
