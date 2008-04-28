From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] add compat support for getsockopt (MCAST_MSFILTER)
Date: Sun, 27 Apr 2008 23:54:56 -0700
Message-ID: <OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com>
References: <20080428.153650.57555735.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:53117 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762476AbYD1GzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 02:55:04 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3S6t3kt027615
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 02:55:03 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3S6t39S196730
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 00:55:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3S6t22G003821
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 00:55:03 -0600
In-Reply-To: <20080428.153650.57555735.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/27/2008 
11:36:50 PM:

> IMHO, It's much better to split into 2 pathces - bug fixes and
> getsockopt() support...

        Ordinarily, I'd agree, but I came across this in the
getsockopt code which has the same issue and both the
new code and fix require the same #define that's in the
getsockopt code. I retested all of it before submitting, too.

                                                        +-DLS

