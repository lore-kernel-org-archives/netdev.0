From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/2] net: if_arp: add ARPHRD_RAWIP type
Date: Wed, 30 Oct 2013 23:26:37 +0100
Message-ID: <C93A6A6E-D5BF-4008-8B4B-496A551DF70F@holtmann.org>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com> <1383124271-15290-2-git-send-email-jukka.rissanen@linux.intel.com> <20131030.172556.454916501978452298.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15283307.onlinehome-server.info ([87.106.208.187]:60320 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab3J3W0m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 18:26:42 -0400
In-Reply-To: <20131030.172556.454916501978452298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>> This is used when there is no L2 header before IP header.
>> Example of this is Bluetooth 6LoWPAN network.
>> 
>> The RAWIP header type value is already used in some Android kernels
>> so same value is used here in order not to break userspace.
>> 
>> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> 
> I'm not applying patches like this until there is an actual user,
> and this therefore goes for patch #2 as well.

patches for Bluetooth 6loWPAN have been posted to linux-bluetooth for review. So there is an actual user here.

If you do not want to merge these patches at this point, that is totally fine. We can happily carry them through bluetooth-next and wireless-next trees as well.

Posting them on netdev is mainly for checking that the changes we have to make outside the Bluetooth subsystem are in sync. So that they are reviewed and have been seen before. If you have any general objections to these assignments or changes, please let us now.

Regards

Marcel
