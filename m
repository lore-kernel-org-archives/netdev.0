From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] e1000: make ioport free
Date: Fri, 27 Jun 2008 21:24:03 +0900
Message-ID: <4864DBE3.3040801@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com> <485B1C31.4020507@jp.fujitsu.com> <486483DF.5060404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com, jeffrey.t.kirsher@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:35395 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYF0MYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 08:24:19 -0400
In-Reply-To: <486483DF.5060404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff

Jeff Garzik wrote:
> Taku Izumi wrote:
>> This patch makes e1000 driver ioport-free.
>> This corrects behavior in probe function so as not to request ioport
>> resources as long as they are not really needed. This is based on the
>> ioport-free patch of e1000 driver from Auke Kok and Tomohiro Kusumi.
>>
>>
>> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> ---
>>  drivers/net/e1000/e1000.h      |    4 +
>>  drivers/net/e1000/e1000_main.c |   88 +++++++++++++++++++++++++++++++++++------
>>  2 files changed, 80 insertions(+), 12 deletions(-)
>
> ACK but failed to apply
>

I'll re-create one.

Taku Izumi <izumi.taku@jp.fujitsu.com>


