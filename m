From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 13:37:26 +0000
Message-ID: <562F7E16.2070906@oracle.com>
References: <20151024023054.GZ22011@ZenIV.linux.org.uk>	<201510270908.t9R9873a001683@room101.nl.oracle.com>	<562F577E.6000901@oracle.com> <20151027.064228.237119117273824839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47959 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbbJ0Nhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 09:37:31 -0400
In-Reply-To: <20151027.064228.237119117273824839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 13:42, David Miller wrote:

> This semantic would only exist after Linux version X.Y.Z and vendor
> kernels that decided to backport the feature.
>
> Ergo, this application would ironically be non-portable on Linux
> machines.

Yes, that's true enough, until nobody was using the old versions any more.

> If portable Linux applications have to handle the situation using
> existing facilities there is absolutely zero value to add it now
> because it only will add more complexity to applications handling
> things correctly because they will always have two cases to somehow
> conditionally handle under Linux.
>
> And if the intention is to just always assume the close() semantic
> thing is there, then you have given me a disincentive to ever add the
> facility.

If you took that argument to it's logical extreme they you'd never make 
any changes that made changes to existing behaviour, and that's patently 
not the case.

-- 
Alan Burlison
--
