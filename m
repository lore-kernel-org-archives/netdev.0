From: Dean Gehnert <deang@tpi.com>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO
 path
Date: Thu, 22 Jan 2015 15:09:31 -0800
Message-ID: <54C1832B.9080506@tpi.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <20150121150159.GS26493@n2100.arm.linux.org.uk> <54C1443C.80909@tpi.com> <20150122210951.GC26493@n2100.arm.linux.org.uk> <54C16B43.5040504@tpi.com> <20150122214910.GD26493@n2100.arm.linux.org.uk> <20150122230622.GA14472@n2100.arm.linux.org.uk>
Reply-To: deang@tpi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([74.45.170.26]:55086 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbbAVXJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:09:32 -0500
In-Reply-To: <20150122230622.GA14472@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 03:06 PM, Russell King - ARM Linux wrote:
> On Thu, Jan 22, 2015 at 09:49:10PM +0000, Russell King - ARM Linux wrote:
>> On Thu, Jan 22, 2015 at 01:27:31PM -0800, Dean Gehnert wrote:
>>> Can you can try the SOCAT test on your Dove platform and see if that passes
>>> the non-cache line aligned test case? I think what the SOCAT test does is
>>> take the NFS "variable" out of the equation. My theory is that if there is a
>>> DMA corruption, then hard telling what kinds of problems will occur. It
>>> might be the payload of a file is corrupted, or if the NFS structures are
>>> corrupted, it could manifest itself as a problem in the NFS code.
>> Anyway, I'm running the test now, but I had to change the socat line to:
>>
>> # socat -b$(((1024*10)+1)) -u open:ExpectData.in TCP:192.168.1.212:4000
>>
>> The receiving end is getting:
>>
>> 4a4727232209b85badc1ca25ed4df222  -
>> 4a4727232209b85badc1ca25ed4df222  -
>> 4a4727232209b85badc1ca25ed4df222  -
>> 4a4727232209b85badc1ca25ed4df222  -
>> 4a4727232209b85badc1ca25ed4df222  -
>> ...
> It's been running for about an hour now with no sign of any problem.
>
It should show the problem in the 1st or 2nd iteration and then continue 
after that... I don't think your Dove shows the problem.
