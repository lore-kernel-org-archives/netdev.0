From: mabbas <mabbas@linux.intel.com>
Subject: Re: [d80211] connecting to B-mode AP
Date: Fri, 15 Sep 2006 10:19:25 -0700
Message-ID: <450AE09D.2040901@linux.intel.com>
References: <C86180A8C204554D8A3323D8F6B0A29F01785286@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:21113 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S932093AbWIORTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 13:19:20 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01785286@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of mabbas
> Sent: Thursday, September 14, 2006 4:25 PM
> To: netdev@vger.kernel.org
> Subject: [d80211] connecting to B-mode AP
>
> When I connect to b-mode only AP and then run iwconf it shows it as a
> G-mode AP. I guess when we set frequency it look through all the modes
> and set the mode to the first channel it founds. since B and G share the
> same frequencies it will set phymode to G. How can we force it to set
> phymode to the AP we are associating with.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
