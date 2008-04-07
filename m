From: "Andrew Brampton" <andrew@bramp.freeserve.co.uk>
Subject: Re: sock_get_timestamp() ktime_to_timeval returns -2?
Date: Mon, 7 Apr 2008 22:57:50 +0100
Message-ID: <01a801c898fa$6cd95ed0$0a00a8c0@Andrew>
References: <013101c89683$1bd00940$0a00a8c0@Andrew> <47F772C7.6020700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pih-relay05.plus.net ([212.159.14.132]:55055 "EHLO
	pih-relay05.plus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbYDGV6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 17:58:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric Dumazet"
>
> I believe the following patch should make sure ENOENT is delivered to the
> application. And yes, SIOCGSTAMP has a meaning only for UDP or other 
> packet
> protocols.
>

Thanks Eric, I didn't expect someone to identify and fix this bug so 
quickly!. I have tested your patch and my problems have gone away.

thanks
Andrew 

