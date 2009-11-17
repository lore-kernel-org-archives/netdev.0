From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: net-next-2.6 compilation errors: missing wireless/i82593.h
Date: Tue, 17 Nov 2009 06:59:14 -0500
Message-ID: <4B029012.6030202@gmail.com>
References: <4B028A37.1010202@gmail.com> <20091117.034428.47467823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:45697 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997AbZKQL7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 06:59:10 -0500
In-Reply-To: <20091117.034428.47467823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Tue, 17 Nov 2009 06:34:15 -0500
> 
>> For the past 9-10 days, net-next-2.6 has failed to compile.  In
>> addition to the errors and warnings already reported here last week,
> 
> Those seemed to be for Android drivers and such, so I hope you
> reported those failures to the driver maintainers as well as
> linux-kernel.
> 
I did, at least some of them.  Nothing seems to have been fixed yet.


> For the time being could you just disable those drivers in your
> build just to get work done or do you absolutely need them?
> 
I did, at least some of them.  Of course, since I'm making changes to
linux/tcp.h and net/tcp.h, an awful lot of drivers seem to include them
one way or another, and I'm trying to ensure nothing breaks (at least
for compilation purposes).


>> since Nov 12th there has been another missing file.  I kept hoping
>> it was temporary, but no joy.
>>
>> /home/administer/net-next-2.6/drivers/net/znet.c:107:29: error:
>> wireless/i82593.h: No such file or directory
> 
> That header file got moved out to drivers/staging along with the
> wavelan driver.
> 
Too bad that CONFIG_STAGING "N" (# CONFIG_STAGING is not set) doesn't
actually turn off all the staging....


> John please fix this up, thanks!
> 
Please.
