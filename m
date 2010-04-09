From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Fri, 9 Apr 2010 02:19:45 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4F6B39F@rrsmsx501.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
	<20100405.161221.159637463.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
	<20100405.165317.89399272.davem@davemloft.net>
 <20100408175444.1e0da2c6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40740 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab0DIITt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:19:49 -0400
In-Reply-To: <20100408175444.1e0da2c6@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 05 Apr 2010 16:53:17 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>> Date: Mon, 5 Apr 2010 17:50:38 -0600
>> 
>>> David Miller wrote:
>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>> Date: Mon, 5 Apr 2010 17:03:56 -0600
>>>> 
>>>>> David Miller wrote:
>>>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>>>> Date: Tue, 23 Mar 2010 12:28:08 -0600
>>>>>> 
>>>>>>> Bisecting points to this patch:
>>>>>>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
>>>>>>> 
>>>>>>> And I confirmed that the issue goes away after reverting it.
>>>>>>> 
>>>>>>> Steps to reproduce:
>>>>>>> 1. Load the driver and configure IPv6 address.
>>>>>>> 2. Run ethtool diag:
>>>>>>> ethtool -t eth0
>>>>>>> 
>>>>>>> 3. If this doesn't brake it try again, or just do ifdown/up.
>>>>>>> Other operations on the interface will eventually panic the
>>>>>>> system: 
>>>>>> 
>>>>>> Stephen please fix this, thanks.
>>>>> 
>>>>> Just FYI - I still see this issue with latest pull from net-2.6.
>>>> 
>>>> It's net-next-2.6 that introduced the problem and has the follow-on
>>>> fixes, not net-2.6
>>> 
>>> Same in net-next:
>> 
>> Ok, Stephen please look into this, we've had this regression
>> for almost two weeks now.
> 
> I can't reproduce it, on e1000e.
> Since the symptoms match the original problem that you already fixed,
> I have to assume that it is fixed but the reporter (Emil) had not
> updated his kernel correctly.

My tree is up to date, but can you point me to the patch that is supposed to fix this?

Thanks,
Emil