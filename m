From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/04] smc91x: request bus width using platform data
Date: Thu, 21 Feb 2008 11:46:19 +0900
Message-ID: <aec7e5c30802201846m160ac39ao15abe8adad7f871a@mail.gmail.com>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
	 <alpine.LFD.1.00.0802201028570.2732@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: "Nicolas Pitre" <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.247]:60853 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbYBUCqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 21:46:20 -0500
Received: by ag-out-0708.google.com with SMTP id 33so4924705agc.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 18:46:19 -0800 (PST)
In-Reply-To: <alpine.LFD.1.00.0802201028570.2732@xanadu.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 12:36 AM, Nicolas Pitre <nico@cam.org> wrote:
> On Wed, 20 Feb 2008, Magnus Damm wrote:
>
>  > These patches make it possible to request bus width in the platform data.
>  >
>  > Instead of keep on updating smc91x.h with board specific configuration,
>  > use platform data to pass along bus width and irq flags to the driver.
>  > This change is designed to be backwards-compatible, so all boards configured
>  > in the header file should just work as usual.
>
>  Thank you for doing this work.  I really meant to do it, and commit
>  09779c6df2dbe95483269d194b327d41fe2cc57e was the first step towards that
>  goal, but as you can see we're nearly two years later and I didn't do
>  it.

It's only a lot of boring search and replace work so I don't blame you
for not doing it. =) I'm glad that you like the idea of keeping bus
width flags with the platform data. Hopefully this will make it easier
to support smc91x on a wide range of boards.

>  I have a few comments though.  I will reply to those messages
>  separately.

Great, thanks. Please let me know which way you think is the best and
I'll rework the patches and repost.

Cheers,

/ magnus
