From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: RE: [PATCH] ep93xx_eth.c: general cleanup
Date: Wed, 30 Dec 2009 13:03:00 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F635@mi8nycmail19.Mi8.com>
References: <BD79186B4FD85F4B8E60E381CAEE19090200ED0C@mi8nycmail19.Mi8.com><20091216183200.GN1819@mail.wantstofly.org><BD79186B4FD85F4B8E60E381CAEE19090200ED18@mi8nycmail19.Mi8.com> <20091223.141458.193725880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<joe@perches.com>
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og107.obsmtp.com ([64.18.1.208]:42021 "HELO
	exprod6og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752486AbZL3SDC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:03:02 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091223.141458.193725880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, December 23, 2009 3:15 PM, David Miller wrote:
> From: "H Hartley Sweeten" <hartleys@visionengravers.com>
> Date: Wed, 16 Dec 2009 13:34:55 -0500
>
>> Wednesday, December 16, 2009 11:32 AM, Lennert Buytenhek wrote:
>>> On Wed, Dec 16, 2009 at 01:18:13PM -0500, H Hartley Sweeten wrote:
>>>
>>>> V3 - Change pr_fmt() as suggested by Joe Perches
>>>>      Don't remove DRV_MODULE_NAME and DRV_MODULE_VERSION
>>>>      Don't remove the message in ep93xx_eth_init_module()
>>>
>>> That's not what I meant, but alright, as you prefer.
>> 
>> Guess my parser is off line today.... ;-)
>> 
>> What did you mean?
>
> This patch also doesn't apply to current sources, so if you
> could also please respin this once you've resolved the feedback
> that would be great.

Lennert,

Since I need to respin this patch what did you mean by this comment?

On Wednesday, December 16, 2009 11:09 AM, Lennert Buytenhek wrote:
> On Wed, Dec 16, 2009 at 01:06:10PM -0500, H Hartley Sweeten wrote:
>
>>>> General cleanup of the ep93xx_eth driver.
>>>
>>> Apart from keeping DRV_MODULE_NAME and DRV_MODULE_VERSION, I have
>>> no strong opinion about this one way or the other.  So I guess that
>>> means ACK.
>> 
>> I will add back the DRV_MODULE_NAME and DRV_MODULE_VERSION and repost.
>> 
>> What about the message in ep93xx_eth_init_module()?  Would you prefer
>> that one to stay?
>
> Most drivers I'm familiar with print a version message when they are
> first instantiated -- perhaps that makes more sense.

I will wait for your reply before updating the patch.

Thanks,
Hartley
