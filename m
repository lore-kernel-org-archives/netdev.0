From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [PATCH v2 0/7] can: CAN network device driver interface and drivers
Date: Tue, 12 May 2009 12:46:11 +0200
Message-ID: <4A095373.9010205@volkswagen.de>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com> <4A094833.7030006@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ltp-list <ltp-list@lists.sf.net>, socketcan-users@lists.berlios.de,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:28030 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbZELKxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 06:53:09 -0400
In-Reply-To: <4A094833.7030006@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Subrata Modak wrote:
>> Hi Oliver/Wolfgang,
>>
>>> Hello,
>>>
>>> here comes v2 of the patch series posted some time ago. See
>>>
>>>  http://marc.info/?l=linux-netdev&m=123507025810612&w=4.
>>>
>>> Changes since v1:
> [...]
>> Would you also like to send a patch to update the testcases for CAN in LTP
>> (http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network/can/filter-tests/) ?
>> These tests were originally picked up from:
>> http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=877&amp;sc=1
>
> The existing tests uses the vcan (virtual CAN) driver, which is not
> affected by these patches. Are you thinking about tests using *real* CAN
> devices?
>

Hi Subrata,

indeed extending the test-cases to the real CAN drivers would urge you 
to add a least
two hardware CAN-interfaces to your test system and wire them correctly 
with the
appropriate termination.
It's like having *all* ethernet cards available in your linux box to 
test them ;-)
Some of these CAN controllers are only available as an on-chip device
(e.g. for some PowerPC CPUs).

If there is some room for LTP improvements, i would tend to create some 
more test-cases
for the networklayer stuff in linux/net/can using the existent virtual 
CAN driver.

Best regards,
Oliver

