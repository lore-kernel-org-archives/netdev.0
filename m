From: David Hendel <david@silicom.co.il>
Subject: RE: ethtool patch to support bypass / fail-to-wire function
Date: Wed, 11 Jun 2014 16:55:27 +0000
Message-ID: <3BFAEADE799AF145974162DF00E013AF018F79A137@exchange2010.silicom.local>
References: <3BFAEADE799AF145974162DF00E013AF018F794DE5@exchange2010.silicom.local>
	<1402322812.23860.76.camel@deadeye.wl.decadent.org.uk>
	<3BFAEADE799AF145974162DF00E013AF018F798C22@exchange2010.silicom.local>
 <20140611091757.78e1002d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Elad Blatt <eladb@silicom.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 105.74.80-QoS-user.in-addr.arpa ([80.74.105.217]:63345 "EHLO
	exchange2010.silicom.local" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753048AbaFKQze convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:55:34 -0400
In-Reply-To: <20140611091757.78e1002d@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
OK, so what should be the next step? How do we move forward with that?

Regards, David


-----Original Message-----
From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
Sent: Wednesday, June 11, 2014 7:18 PM
To: David Hendel
Cc: netdev@vger.kernel.org; Elad Blatt
Subject: Re: ethtool patch to support bypass / fail-to-wire function

The driver using this is not upstream. You need to get that driver reviewed and incorporated in upstream kernel before the changes to ethtool will be considered.

I expect that the driver will not be accepted as is, and therefore you will have to make changes (including API changes), that render this ethtool API moot.
