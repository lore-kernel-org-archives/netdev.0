From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Sun, 15 Apr 2012 22:11:26 -0700
Message-ID: <4F8BA9FE.4010905@intel.com>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com> <20120216094936.3449e6ef@nehalam.linuxnetplumber.net> <1329417315.30697.3.camel@lb-tlvb-eilong.il.broadcom.com> <4F3D5B47.6030505@intel.com> <1329422255.30697.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Stephen Hemminger <shemminger@vyatta.com>,
	Ariel Elior <ariele@broadcom.com>, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35467 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab2DPFL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 01:11:27 -0400
In-Reply-To: <1329422255.30697.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/2012 11:57 AM, Eilon Greenstein wrote:
>>>> "Ariel Elior" <ariele@broadcom.com> wrote:
>>>>
>>>>> In 57712 and 578xx the tx-switching module parameter allows the user to control
>>>>> whether outgoing traffic can be loopbacked into the device in case there is a
>>>>> relevant client for the data using the same device for rx.

[...]

>>> But netdev is a great place to ask - are there other vendors out there
>>> that requires this control over internal switching? If so, we can define
>>> a new ethtool command. The alternative of using the ethtool private
>>> flags seems just as inconvenient from administrators point of view and
>>> also seem less appropriate since this configuration is more likely to be
>>> the same for all PFs on the same machine.
>>>

[...]

> OK, thanks John. Dave - please do not apply this patch. We need to look
> at the alternatives suggested by John.
> 
> Thanks,
> Eilon
> 

Eilon, any progress with this? We need this to support VEPA modes in
macvlan running over SR-IOV devices or other embedded switches. The
problem being if the stacked device expects the packet to be sent
to the reflexive relay on the switch in the SR-IOV case the embedded
switch may not actually do this.

Thanks,
John
