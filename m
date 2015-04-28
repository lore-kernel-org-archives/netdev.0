From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v2] be2net: log link status
Date: Tue, 28 Apr 2015 21:32:10 +0200
Message-ID: <553FE03A.3060503@redhat.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com>	<447118c7-cb5e-4e64-88cc-8205cadfaf5e@CMEXHTCAS2.ad.emulex.com>	<553F9A05.3020704@redhat.com> <20150428.124437.1485751826549036802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sathya.Perla@Emulex.Com, netdev@vger.kernel.org,
	subbu.seetharaman@Emulex.Com, Ajit.Khaparde@Emulex.Com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030721AbbD1TcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 15:32:15 -0400
In-Reply-To: <20150428.124437.1485751826549036802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2015 06:44 PM, David Miller wrote:
> From: Ivan Vecera <ivecera@redhat.com>
> Date: Tue, 28 Apr 2015 16:32:37 +0200
>
>> On 04/23/2015 08:31 AM, Sathya Perla wrote:
>>>> -----Original Message-----
>>>> From: Ivan Vecera [mailto:ivecera@redhat.com]
>>>>
>>>> The driver unlike other drivers does not log link state changes.
>>>>
>>>> v2: added current link speed to log message
>>>>
>>> Ivan, I disagree with the v2 change. I think your original intention
>>> was just to log a message when the link goes up or down
>>> asynchronously (i.e., without any user intervention.)
>>> After alerting the user, if the user wants to know other link
>>> properties like speed, duplex etc then the ethtool cmd needs
>>> to be used; there is no need to log a message with those details.
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> Dave, could we apply the v1 WRT Sathya's comment?
>
> Patches should be resubmitted freshly when people want me to do something
> like this.
>
> Thanks.
>
OK... will repost v1.
