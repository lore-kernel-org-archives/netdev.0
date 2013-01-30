From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/13] ixgbe: Adding Tx encapsulation capability
Date: Wed, 30 Jan 2013 09:48:23 -0800
Message-ID: <1359568103.30177.13.camel@edumazet-glaptop>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1359546286-18179-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <51095146.7030404@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:48609 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756338Ab3A3RsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 12:48:25 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so1093917pbc.12
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 09:48:25 -0800 (PST)
In-Reply-To: <51095146.7030404@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 08:58 -0800, Alexander Duyck wrote:
> NAK, this is not a production patch.  This was just meant to be proof of
> concept code.

Well, this was the most interesting part of this serie for me ;)

What is missing to reach production level ?

hw_enc_features is in net-next with no user yet, I was eager to see
the first implementation...

if (skb->encapsulation)
	features &= dev->hw_enc_features;
