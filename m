From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Wed, 09 Dec 2009 10:43:10 +0200
Message-ID: <4B1F631E.5030908@embedded-sol.com>
References: <4B056158.5060104@embedded-sol.com>	<4B056D85.5010904@embedded-sol.com> <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:56562 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbZLIInE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 03:43:04 -0500
In-Reply-To: <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Did you have a chance to look into this problem ?

Thanks a lot.

Felix.
 
Michael Chan wrote:
> On Thu, 2009-11-19 at 08:08 -0800, Felix Radensky wrote:
>   
>> Hi,
>>
>> The problem goes away if I remove the call to
>>
>> tg3_set_power_state(tp, PCI_D3hot);
>>
>> from tg3_close().
>>     
>
> Added Matt to CC.  He is on vacation and may not be able to look into
> this right away.  Thanks.
>
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
>   

