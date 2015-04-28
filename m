From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v2] be2net: log link status
Date: Tue, 28 Apr 2015 16:32:37 +0200
Message-ID: <553F9A05.3020704@redhat.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com> <447118c7-cb5e-4e64-88cc-8205cadfaf5e@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Subramanian Seetharaman <subbu.seetharaman@Emulex.Com>,
	Ajit Kumar Khaparde <Ajit.Khaparde@Emulex.Com>,
	David Miller <davem@davemloft.net>
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965773AbbD1Ocr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 10:32:47 -0400
In-Reply-To: <447118c7-cb5e-4e64-88cc-8205cadfaf5e@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 08:31 AM, Sathya Perla wrote:
>> -----Original Message-----
>> From: Ivan Vecera [mailto:ivecera@redhat.com]
>>
>> The driver unlike other drivers does not log link state changes.
>>
>> v2: added current link speed to log message
>>
> Ivan, I disagree with the v2 change. I think your original intention
> was just to log a message when the link goes up or down
> asynchronously (i.e., without any user intervention.)
> After alerting the user, if the user wants to know other link
> properties like speed, duplex etc then the ethtool cmd needs
> to be used; there is no need to log a message with those details.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Dave, could we apply the v1 WRT Sathya's comment?

Thanks,
Ivan
