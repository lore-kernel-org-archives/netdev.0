From: "Paoloni, Gabriele" <gabriele.paoloni@intel.com>
Subject: RE: PATCH_ppp_mp_explode_redesign
Date: Thu, 19 Mar 2009 11:57:25 +0000
Message-ID: <B53FBD69205CDD4EA91C63A5E0E0BE791EE5182B@irsmsx502.ger.corp.intel.com>
References: <49AD1AAB.mail7XX11MN1A@intel.com>
 <20090313.160929.74391613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulus@samba.org" <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42737 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbZCSL5h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:57:37 -0400
In-Reply-To: <20090313.160929.74391613.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many thanks for that.

Just a question:
Does it mean that I should see my patch applied in the next Linux kernel stable version?

Best Regards

Gabriele Paoloni

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: 13 March 2009 23:09
To: Paoloni, Gabriele
Cc: netdev@vger.kernel.org; paulus@samba.org
Subject: Re: PATCH_ppp_mp_explode_redesign

From: gabriele.paoloni@intel.com
Date: Tue, 03 Mar 2009 11:55:23 +0000

> Problem Solution:
> 
> The problem has been solved by redesigning the "ppp_mp_explode" function in such 
> a way to make it split the sk_buff buffer according to the speeds of the underlying 
> PPP channels (the speeds of the serial interfaces respectively attached to the PPP 
> channels). Referring to the above example, the redesigned "ppp_mp_explode" function 
> will now divide the 1000 Bytes buffer into two fragments whose sizes are set 
> according to the speeds of the channels where they are going to be sent on (e.g . 
> 10 Byets on 10KB/sec channel and 990 Bytes on 1000KB/sec channel). 
> The reworked function grants the same performances of the original one in optimal 
> working conditions (i.e. a bundle made up of PPP links all working at the same 
> speed), while greatly improving performances on the bundles made up of channels 
> working at different speeds.

Looks good, applied.

---------------------------------------------------------------------
Intel Shannon Limited
Registered in Ireland
Registered Office: One Spencer Dock, North Wall Quay, Dublin 1
Registered Number: 308263
Business address: Dromore House, East Park, Shannon, Co. Clare

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

