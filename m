From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Mon, 5 Apr 2010 17:03:56 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4ADAB2A@rrsmsx501.amr.corp.intel.com>
 <20100323.233323.93371615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "shemminger@vyatta.com" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38435 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756816Ab0DEXD7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 19:03:59 -0400
In-Reply-To: <20100323.233323.93371615.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Tue, 23 Mar 2010 12:28:08 -0600
> 
>> Bisecting points to this patch:
>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
>> 
>> And I confirmed that the issue goes away after reverting it.
>> 
>> Steps to reproduce:
>> 1. Load the driver and configure IPv6 address.
>> 2. Run ethtool diag:
>> ethtool -t eth0
>> 
>> 3. If this doesn't brake it try again, or just do ifdown/up. Other
>> operations on the interface will eventually panic the system: 
> 
> Stephen please fix this, thanks.

Just FYI - I still see this issue with latest pull from net-2.6.

Thanks,
Emil