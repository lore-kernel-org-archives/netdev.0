From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 0/7] can: CAN network device driver interface and drivers
Date: Tue, 12 May 2009 11:58:11 +0200
Message-ID: <4A094833.7030006@grandegger.com>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	ltp-list <ltp-list@lists.sf.net>,
	socketcan-users@lists.berlios.de, netdev@vger.kernel.org
To: Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:59611 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbZELJ6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 05:58:14 -0400
In-Reply-To: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subrata Modak wrote:
> Hi Oliver/Wolfgang,
> 
>> Hello,
>>
>> here comes v2 of the patch series posted some time ago. See
>>
>>  http://marc.info/?l=linux-netdev&m=123507025810612&w=4.
>>
>> Changes since v1:
[...]
> Would you also like to send a patch to update the testcases for CAN in LTP
> (http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network/can/filter-tests/) ?
> These tests were originally picked up from:
> http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=877&amp;sc=1

The existing tests uses the vcan (virtual CAN) driver, which is not
affected by these patches. Are you thinking about tests using *real* CAN
devices?

Wolfgang.
