From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Multicast socket option
Date: Fri, 29 May 2009 08:06:40 -0700
Message-ID: <4A1FFA00.7090202@us.ibm.com>
References: <4A1EC33E.1080201@us.ibm.com> <20090529103556.GA4160@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:40725 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760757AbZE2PGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 11:06:42 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4TF27JD012620
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 11:02:07 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4TF6hD1249524
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 11:06:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4TF6fMo004927
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 11:06:43 -0400
In-Reply-To: <20090529103556.GA4160@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:

>> 	if (!pmc)
>> -		return 1;
>> +		return inet->mc_all;
> 
> This change also filters out broadcasts sent to sockets listening on a given
> port.  Is that what you want?

Yes, as Christoph pointed out, this does not impact
broadcast delivery, which will remain consistent with
original behaviour.

thanks,
Nivedita
