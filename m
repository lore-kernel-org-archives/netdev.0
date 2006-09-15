From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [d80211] connecting to B-mode AP
Date: Fri, 15 Sep 2006 11:46:19 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01785374@dhost002-46.dex002.intermedia.net>
References: <450AE09D.2040901@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:11092 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932180AbWIOSqX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 14:46:23 -0400
Content-class: urn:content-classes:message
in-reply-to: <450AE09D.2040901@linux.intel.com>
To: "mabbas" <mabbas@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

But it's not the AP connection type that determines what rates are
available - it's the available rate set - this is independent of whether
the card is B or G. A G AP may only advertise B rates, even though it's
a G AP. I still don't see any need to change the phytype.

Simon


-----Original Message-----
From: mabbas [mailto:mabbas@linux.intel.com] 
Sent: Friday, September 15, 2006 10:19 AM
To: Simon Barber
Cc: netdev@vger.kernel.org
Subject: Re: [d80211] connecting to B-mode AP

Simon Barber wrote:
> Why is it necessary to set phymode to B? - a G client can connect 
> perfectly well to a B AP.
>   
We need this information for rate scaling and we need to send the NIC
different command depends on the AP connection type.
Mohamed
> Simon
>
> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of mabbas
> Sent: Thursday, September 14, 2006 4:25 PM
> To: netdev@vger.kernel.org
> Subject: [d80211] connecting to B-mode AP
>
> When I connect to b-mode only AP and then run iwconf it shows it as a 
> G-mode AP. I guess when we set frequency it look through all the modes

> and set the mode to the first channel it founds. since B and G share 
> the same frequencies it will set phymode to G. How can we force it to 
> set phymode to the AP we are associating with.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in 
> the body of a message to majordomo@vger.kernel.org More majordomo info

> at http://vger.kernel.org/majordomo-info.html
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in 
> the body of a message to majordomo@vger.kernel.org More majordomo info

> at  http://vger.kernel.org/majordomo-info.html
>   
