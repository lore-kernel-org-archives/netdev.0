From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Mon, 08 Dec 2014 12:41:34 +0100
Message-ID: <54858E6E.7010707@redhat.com>
References: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com> <20141207081928.GA2215@casper.infradead.org> <20141208110301.GA1885@nanopsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, roopa@cumulusnetworks.com,
	sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbaLHLmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 06:42:54 -0500
In-Reply-To: <20141208110301.GA1885@nanopsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2014 12:03 PM, Jiri Pirko wrote:
> Sun, Dec 07, 2014 at 09:19:28AM CET, tgraf@suug.ch wrote:
>> On 12/06/14 at 10:54pm, roopa@cumulusnetworks.com wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>

Please provide a normal, non-empty commit message as
everyone else ...

>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
...
>>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>> index fded127..9f1d256 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>> @@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>>   				      u32 filter_mask)
>>>   {
>>>   	struct rocker_port *rocker_port = netdev_priv(dev);
>>> -	u16 mode = BRIDGE_MODE_SWDEV;
>>> +	u16 mode = -1;
>>         ^^^
>> I assume you meant s16
>
> well, I see no problem in using u16. IFLA_BRIDGE_MODE attr is u16 so
> mode should stay u16.
>
> But maybe better to add:
> #define BRIDGE_MODE_UNDEF 0xFFFF

Yep, something along these lines seems better.
