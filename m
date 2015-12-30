From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] be2net: patch set
Date: Wed, 30 Dec 2015 12:44:28 -0500 (EST)
Message-ID: <20151230.124428.2134209153288077070.davem@davemloft.net>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
	<20151229.155054.404543929028869618.davem@davemloft.net>
	<CAKvpyk0X3ZncKWdz-a+Ek9XvC8brvJssKzwz+MQHNZv6c2MKPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbbL3Roc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:44:32 -0500
In-Reply-To: <CAKvpyk0X3ZncKWdz-a+Ek9XvC8brvJssKzwz+MQHNZv6c2MKPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@avagotech.com>
Date: Wed, 30 Dec 2015 11:57:18 +0530

> On Wed, Dec 30, 2015 at 2:20 AM, David Miller <davem@davemloft.net> wrote:
>>
>> Please fix the problems reported by the kbuild test robot, they happened
>> when I tried to build this too.
> 
> David, the test robot is complaining that all values of the enum are
> not being handled by the switch statement.

That is a legitimate warning, and we fix those wherever they occur.

Don't even try to argue that leaving the gcc warning in new code
is legitimate.
