From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: skb->timestamp == 0.000000 ?
Date: Mon, 21 Nov 2011 16:11:40 -0500
Message-ID: <20111121211140.GB24753@d2.suse.de>
References: <CAJX4=r3wTn9v6-5oEpGdeKkFjKsRLZwc76tE9M4FiVJX4Lpisg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Felipe Dias <felipediassss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41503 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab1KUVLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:11:46 -0500
Received: by mail-fx0-f46.google.com with SMTP id n18so6454508fag.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 13:11:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJX4=r3wTn9v6-5oEpGdeKkFjKsRLZwc76tE9M4FiVJX4Lpisg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/19 18:13, Felipe Dias wrote:
> Hi..
> 
> Please let me know if this isnt right list to this kind of question.
> 
> I'm registering a new protocol handler with dev_add_pack. I would like
> to know only the difference between timestamp on skb->tstamp and the
> time of reception by my module.
> 
> So I do:
> ----
> struct timeval time_skb, time_module;
> do_gettimeofday(&time_module):
> skb_get_timestamp(skb, &time_skb);
> ---
> 
> And time_skb.tv_sec and time_skb.tv_usec are equal to 0;
> 
> I'm doing some wrong ?

Timestamps have to be enabled
have a look at:
net_enable_timestamp()

-Ben
