From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback mode.
Date: Tue, 4 Jan 2011 18:06:40 -0800
Message-ID: <AANLkTinWtLNGaNezxe0qMwDP3LQvAV7L_k_QPrwsar=e@mail.gmail.com>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	<1294187401-4662-1-git-send-email-maheshb@google.com>
	<20110104163645.0b3a3687@nehalam>
	<1294190504.2992.3.camel@localhost>
	<20110104172939.711b758d@nehalam>
	<4D23CAA5.7060902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:27577 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab1AECGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 21:06:45 -0500
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p0526hHa009751
	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 18:06:43 -0800
Received: from bwz10 (bwz10.prod.google.com [10.188.26.10])
	by hpaq2.eem.corp.google.com with ESMTP id p0526gLS006298
	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 18:06:42 -0800
Received: by bwz10 with SMTP id 10so14976049bwz.20
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 18:06:42 -0800 (PST)
In-Reply-To: <4D23CAA5.7060902@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 4, 2011 at 5:34 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>>> Since this is a boolean it SHOULD go into ethtool_flags rather than
>>>> being a high level operation.
>>>
>>> It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
>>> controlling offload features.
>>
>>
>> It just seems the number of hooks keeps growing which takes more space
>> and increases complexity.
>
> Is there any complication/downside to using flags in the (un?)likely event
> of wanting different flavors of loopback in the card?

The purpose of the patch is to stress / exercise the ingress/egress
path(s). So like Ben had suggested earlier to keep the loopback
implementation as near as possible to the host would streamline /
simplify the implementation & usage.

This is not a new patch and the earlier thread has an answer for this.
It's just that when I re-submitted this patch today, it went in as a
new patch! Here are the reference(s) the old thread -

http://marc.info/?l=linux-netdev&w=3&r=1&s=Allow+ethtool+to+set+interface&q=t

>
> rick jones
>
