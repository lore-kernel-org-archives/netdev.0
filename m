From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH V2] ipconfig: Inform user if carrier is not ready
Date: Fri, 14 Sep 2012 12:19:46 -0700
Message-ID: <50538352.6080406@hp.com>
References: <5052403B.4040408@gmail.com> <20120913.163134.361379133013906511.davem@davemloft.net> <50524419.4080404@gmail.com> <20120913.164525.1171098883605242394.davem@davemloft.net> <50525758.1090609@gmail.com> <50525C5D.8040302@hp.com> <505380A0.7020407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Erwan Velu <erwanaliasr1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:19860 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab2INTTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 15:19:49 -0400
In-Reply-To: <505380A0.7020407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2012 12:08 PM, Erwan Velu wrote:
> From: Erwan Velu <erwanaliasr1@gmail.com>
>
> While using the ip= option at the cmdline, the kernel can hold the boot
> process for 2 minutes (CONF_CARRIER_TIMEOUT) if the carrier is not
> present.
>
> While waiting the carrier, user is not informed about this situation and
> so could think the kernel is frozen.
>
> If we don't get the carrier after some seconds, let's display a message to
> inform the user about the remaining time before reaching the timeout.

That should be much better than upwards of 120 messages.

rick jones
