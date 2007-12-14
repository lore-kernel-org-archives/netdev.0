From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ucc_geth: use rx-clock-name and tx-clock-name device
 tree properties
Date: Fri, 14 Dec 2007 01:45:32 -0500
Message-ID: <4762268C.1020305@garzik.org>
References: <11967166791607-git-send-email-timur@freescale.com> <1196716680381-git-send-email-timur@freescale.com> <1196716685975-git-send-email-timur@freescale.com> <4373ED4B-5EDD-4725-9D99-BE39B0656E19@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Timur Tabi <timur@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45752 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbXLNGpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 01:45:35 -0500
In-Reply-To: <4373ED4B-5EDD-4725-9D99-BE39B0656E19@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> 
> On Dec 3, 2007, at 3:17 PM, Timur Tabi wrote:
> 
>> Updates the ucc_geth device driver to check the new rx-clock-name and
>> tx-clock-name properties first.  If present, it uses the new function
>> qe_clock_source() to obtain the clock source.  Otherwise, it checks the
>> deprecated rx-clock and tx-clock properties.
>>
>> Update the device trees for 832x, 836x, and 8568 to contain the new 
>> property
>> names only.
>>
>> Signed-off-by: Timur Tabi <timur@freescale.com>
>> ---
>>
>> This patch applies to Kumar's for-2.6.25 branch.  ucc_geth will 
>> compile but not
>> run if my other patch, "qe: add function qe_clock_source" has not also 
>> been
>> applied.
> 
> Jeff, I'll take this patch via powerpc.git if you don't have any issue 
> since its just touching probe/setup bits.

ACK



