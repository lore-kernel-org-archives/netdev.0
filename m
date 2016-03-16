From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH 2/2] lan78xx: add ndo_get_stats64
Date: Wed, 16 Mar 2016 16:11:05 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404C92DC@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D404C906A@CHN-SV-EXMX02.mchp-main.com>
 <56E96ABE.1010206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:46671 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751951AbcCPQLI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 12:11:08 -0400
In-Reply-To: <56E96ABE.1010206@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +	storage->rx_length_errors = (stats.rx_undersize_frame_errors +
> > +				     stats.rx_oversize_frame_errors);
> 
>     Parens not needed.
> 
> > +	storage->rx_errors = (stats.rx_fcs_errors +
> > +			      stats.rx_alignment_errors +
> > +			      stats.rx_fragment_errors +
> > +			      stats.rx_jabber_errors +
> > +			      stats.rx_undersize_frame_errors +
> > +			      stats.rx_oversize_frame_errors +
> > +			      stats.rx_dropped_frames);
> 
>     Neither here.
> 
> > +	storage->tx_errors = (stats.tx_fcs_errors +
> > +			      stats.tx_excess_deferral_errors +
> > +			      stats.tx_carrier_errors);
> 
>     And here.
> 

Thanks. Will resubmit.

Woojung
