From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] bridge: multicast: temp and perm entries
 behaviour enhancements
Date: Mon, 20 Jul 2015 22:35:50 +0200
Message-ID: <55AD5BA6.3050101@cumulusnetworks.com>
References: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com> <20150720.124939.1328394717828737521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, stephen@networkplumber.org,
	sashok@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37959 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbGTUfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 16:35:52 -0400
Received: by wibxm9 with SMTP id xm9so37185744wib.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 13:35:51 -0700 (PDT)
In-Reply-To: <20150720.124939.1328394717828737521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2015 09:49 PM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Wed, 15 Jul 2015 07:16:49 -0700
> 
>> Hi,
>> Patch 01 adds a notify when a group is deleted via br_multicast_del_pg()
>> (on expire, on device delete or on device down).
>> Patch 02 changes how bridge device and bridge port delete and down/up are
>> handled. Until now on bridge down all groups were flushed, now only the
>> temp ones are (same for port), perm entries are flushed only on port or
>> bridge removal.
> 
> Series applied, but if patch #2 breaks things for anyone depending upon the
> old behavior of flushing all entries I will have to revert.
> 

Okay, understood.
