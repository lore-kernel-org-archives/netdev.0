From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 12 May 2008 08:52:32 +0200
Message-ID: <4827E930.3000008@krogh.cc>
References: <20080507.141521.193714938.davem@davemloft.net>	<482498D5.9060008@krogh.cc>	<48258074.7060306@krogh.cc> <20080510.213431.193696750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:49526 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756238AbYELGwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 02:52:39 -0400
In-Reply-To: <20080510.213431.193696750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Sat, 10 May 2008 13:01:08 +0200
> 
>> Any good suggestions about the "Transmit timed out" messages. It
>> currently leads to a system that "doesnt die" but doesnt respond within
>> 15 minutes of load of the network adapter.
> 
> It's likely some bug in the driver that hangs the card for whatever
> reason, which we'll need to work out.

Ok. I have been testing a bit more. It generally works fine, It seems
the "transmit timed out" thing was provoked by dd in the tests, because
it was creating a lot of small requests. (default bs=512).(over NFS).
When the  blocksize went up, the problem dissapered. (and the numer of
context-switches went down).

When the blocksize went up, the performance likewise raised to 615MB/s.
I haven't been able to get pass that number.

This is where one of the cpu's are settling at 100% load.

Jesper

-- 
Jesper
