From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC PATCH v3 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Wed, 01 Apr 2015 11:44:17 +0200
Message-ID: <551BBDF1.6070208@hartkopp.net>
References: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net> <1427867429-3909-2-git-send-email-socketcan@hartkopp.net> <551BB555.7030808@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <551BB555.7030808@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 01.04.2015 11:07, Marc Kleine-Budde wrote:
> On 04/01/2015 07:50 AM, Oliver Hartkopp wrote:
  >> +struct uniqframe {
>> +	const struct sk_buff *skb;
>> +	ktime_t tstamp;
>> +};
>
> Nitpick: as ktime_t is always a 64 bit value, I think putting it first
> might provide better alignment.

No objections. Good idea.

>
> No need to repost, I'll change this while applying, if you're okay with
> this.

I would suggest to take both patches into can-next (for 4.1).

Even though I did some testing on my i7 machine I would like this per-CPU 
stuff to come to maturity with some more testing of other users.

IMO the patch 1/2 (aka 'the fix') is not critical - at least it was not for 
the last 10 years :-)

So if $COSTUMER really needs this functionality it should be no problem to 
apply these really short and clear patches.

Best regards,
Oliver

