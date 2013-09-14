From: Andre Naujoks <nautsch2@gmail.com>
Subject: Re: [PATCH net 0/3] SLCAN/SLIP fixes and performance
Date: Sat, 14 Sep 2013 13:22:14 +0200
Message-ID: <523446E6.5060507@gmail.com>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com> <52343E64.1050207@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52343E64.1050207@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.09.2013 12:45, Marc Kleine-Budde wrote:
> On 09/13/2013 07:37 PM, Andre Naujoks wrote:
>> Hi Dave,
>>
>> these are some loosely related patches, that fix an ancient locking problem in
>> the slip and slcan drivers, add general ASCII-HEX to bin functions for
>> uppercase ASCII, fix the handling of CAN RTR frames in the slcan driver
>
> Can you get an Acked-by for the ASCII-HEX functions from the appropriate
> maintainer?

The patch went out to the maintainers I got from the get_maintainer.pl 
script. Is there anything else I can or should do to get an Ack from them?

Regards
   Andre

>
>> and increase the performance for the slcan driver.
>>
>> As these patches mainly contain fixes for the slip/slcan drivers that require
>> a tty layer fix included in 3.11, I would suggest to get the patches in via
>> the net tree for the 3.12 cycle. They should apply properly on the latest net
>> and mainline tree.
>
> Marc
>

