From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH 1/1]: SAs created although tmpl->optional set
Date: Mon, 19 Nov 2007 23:15:18 -0600
Message-ID: <200711200515.lAK5FIuO012350@faith.austin.ibm.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55659 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbXKTFUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:20:33 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAK5KXu3032705
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 00:20:33 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAK5KWEt105104
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 22:20:32 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAK5KWRf022082
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 22:20:32 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Heh I made the same mistake when I first read this piece of
>code too :) The optional flag isn't saying that it doesn't need
>to be protected, but rather that the SA may not be present on
>input.  It's only used for IPComp where we may skip the IPComp
>if the data is not compressible.
>
>In other words the optional flag is really only meaningful on
>inbuond policy checks.

Thanks for clearing that up for me. :-) 
I think it is not documented clearly in ipsec-tools.

Joy
