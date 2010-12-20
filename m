From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Mon, 20 Dec 2010 10:48:14 -0800 (PST)
Message-ID: <20101220.104814.59687502.davem@davemloft.net>
References: <AANLkTimSH_NfX2qno7sO3A4CHLsONmRUDHzWXY4reD28@mail.gmail.com>
	<20101220090352.3ea7ade2@nehalam>
	<4D0F9FCC.7010108@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, nanditad@google.com, netdev@vger.kernel.org,
	therbert@google.com, chavey@google.com, ycheng@google.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932376Ab0LTSrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:47:45 -0500
In-Reply-To: <4D0F9FCC.7010108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 20 Dec 2010 10:26:20 -0800

>> Agree this is a good idea, but some further notes:
>>   * The control of receive window is a local function not covered by
>>     RFC.
>>   * Linux manipulates receive window automatically, unlike some other
>>     implementations.
>> But any change to TCP risks breaking other broken implementations
>> and users need a good way to recover. 
> 
> Always good to be careful, but break in what way?  Many stacks have
> been advertising an initial receive window of well above 10 segments
> going back literally decades.

Agreed.
