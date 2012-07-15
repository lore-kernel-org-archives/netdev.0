From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Sun, 15 Jul 2012 03:42:25 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274F2354@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFCDA6C.8020708@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
 <4FFCF314.6020400@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
 <4FFD0908.6080506@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EF8AD@ORSMSX102.amr.corp.intel.com>
 <4FFE3505.8060407@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F018D@ORSMSX102.amr.corp.intel.com>
 <4FFE3D27.7020500@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F01BE@ORSMSX102.amr.corp.intel.com>
 <4FFE40A9.4060807@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F02D7@ORSMSX102.amr.corp.intel.com>
 <4FFE6BB9.4060106@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
 <4FFE787B.9050201@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
 <4FFF61BD.1060604@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F11FF@ORSMSX102.amr.corp.intel.com>
 <4FFFA532.1030208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41925 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461Ab2GODm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 23:42:27 -0400
In-Reply-To: <4FFFA532.1030208@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Thursday, July 12, 2012 9:34 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/13/12 12:10, Dave, Tushar N wrote:
>>> -----Original Message-----
>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>> Sent: Thursday, July 12, 2012 4:46 PM
>>> To: Dave, Tushar N
>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>> kernel@vger.kernel.org
>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>
>> Thanks for sending full dmesg log. I am still investigating. I think
>this issue can occur if two PCIe link partner *i.e pcie bridge and pcie
>device do not have same max payload size.
>> I need 2 more info.
>> 1) PBA number of the card.
>
>This is a remote server and I could not get this.
>
>> 2) full lspci -vvv output of entire system 'after you have changed max
>payload size to 128'.

Somehow setting max payload to 256 from BIOS does not set this value for all devices. I believe this is a BIOS bug.
All devices in path from root complex to 82571, should have same max payload size otherwise it can cause hang. When you set max payload to 128 from BIOS, all device in path from root complex to 82571 got assigned same max payload size. This resolves the issue.

I hope this helps.

-Tushar
