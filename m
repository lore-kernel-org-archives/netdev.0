From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Tue, 24 Nov 2009 09:14:10 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA6B4DC98@rrsmsx501.amr.corp.intel.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
	 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
	 <1258657155.2837.10.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A200AD@rrsmsx501.amr.corp.intel.com>
	 <1258982570.2845.8.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A9617F@rrsmsx501.amr.corp.intel.com>
 <1259072292.2940.16.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50766 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933194AbZKXQOT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 11:14:19 -0500
In-Reply-To: <1259072292.2940.16.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Tuesday, November 24, 2009 6:18 AM


>> [snip]
>>
>> >
>> >How does this interact with use of multiple queues within a single
>> >function?  Are the specified queue numbers really interpreted as RX
>> >queue indices or as function numbers?
>> >
>> >Ben.
>>
>> Yeah, that is ambiguous.  Would it be better if we changed the name of
>the parameter to 'vf' instead of 'queue' to make it explicit?
>>
>> This would give us:
>> $ ip link set eth1 vf 1 mac <blah>
>>
>> The issue of which VF goes with which PF device can be deduced in
>userspace via sysfs.
>>
>> If we want to make this apply to non SR-IOV queues, then we'll add a new
>parameter later.
>>
>> Works for you?
>
>OK, this sounds reasonable.
>
>Ben.
>

Thanks for looking at this stuff, Ben. I appreciate it. I'll rework the patches and send them out in a few days.

-Mitch
