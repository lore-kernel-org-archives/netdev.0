From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: DLPAR memory add fix
Date: Mon, 01 Oct 2007 11:05:40 -0400
Message-ID: <47010CC4.7000204@garzik.org>
References: <200710011633.18305.ossthema@de.ibm.com> <470107D9.2040301@garzik.org> <200710011654.14067.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41075 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbXJAPFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 11:05:42 -0400
In-Reply-To: <200710011654.14067.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Hi,
> 
> On Monday 01 October 2007 16:44, Jeff Garzik wrote:
>> Jan-Bernd Themann wrote:
>>> Due to stability issues in high load situations the HW queue handling
>>> has to be changed. The HW queues are now stopped and restarted again instead
>>> of destroying and allocating new HW queues. 
>>>
>>> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
>> May I presume this is for 2.6.23?
>>
>> 	Jeff
> 
> no, the patch is build against 2.6.24 upstream (new NAPI interface).

OK, thanks.

Since we typically have two streams, the current bug-fix stream and the 
for-next-kernel stream, please indicate to which kernel/git tree your 
patch applies, in the future.


