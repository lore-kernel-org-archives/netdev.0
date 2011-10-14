From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot device
Date: Fri, 14 Oct 2011 09:06:00 -0700
Message-ID: <4E985DE8.3090308@hp.com>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com> <4E9855EC.1020509@hp.com> <C27F8246C663564A84BB7AB34397724266D2018303@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3756 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843Ab1JNQGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 12:06:04 -0400
In-Reply-To: <C27F8246C663564A84BB7AB34397724266D2018303@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2011 08:53 AM, Michael Chan wrote:
> Rick Jones wrote:
>
>> Is this perhaps saying that a bnx2x-driven device being used for
>> FCoE or iSCSI boot must not permit *any* run-time configuration
>> change which leads to a NIC reset?
>>
>
> That is right.  Unless you have a multipath configuration with multiple
> ports, then you can reset one port at a time.

So, should there also be a "cnic_boot_device" check in many of the 
"capital letter" ethtool paths?

rick
