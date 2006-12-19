From: Andreas Jellinghaus <aj@ciphirelabs.com>
Subject: Re: [ANN] Acrypto asynchronous crypto layer 2.6.19 release.
Date: Tue, 19 Dec 2006 11:51:01 +0100
Message-ID: <4587C415.9020706@ciphirelabs.com>
References: <20061216191521.GA26549@2ka.mipt.ru> <4586458E.6000503@dungeon.inka.de> <20061218095740.GA5219@2ka.mipt.ru> <458690EA.2000405@ciphirelabs.com> <20061218131356.GA11186@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ciphirelabs.net ([217.72.114.64]:45318 "EHLO
	mx1.ciphirelabs.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbWLSKvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 05:51:20 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061218131356.GA11186@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> You can change it in async_provider in compilation time or I can create
> module version. There is an item in related todo list to use crypto
> contexts, they were created exactly for such kind of things (actually
> for hardware devices which do not support realtime key changes).

ok, what do I need to change to get aes-cbc-essiv:sha256 support
so I can use acrypto with my current dm-crypt'ed partitions?

>> would be nice to track those issues, so people testing your patch
>> are aware of the situation.
> 
> I will change acrypto software crypto provider, but right now, yes,
> software crypto only supports one mode.

ok, thanks.

Regards, Andreas
