From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH] igb: fix PHC stopping on max freq
Date: Wed, 20 Mar 2013 22:55:01 +0000
Message-ID: <CD6F8B97.167F1%matthew.vick@intel.com>
References: <20130320201153.7fc5e844@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Stefan Assmann <sassmann@redhat.com>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42844 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955Ab3CTWzH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 18:55:07 -0400
In-Reply-To: <20130320201153.7fc5e844@griffin>
Content-Language: en-US
Content-ID: <BDFF4B58EBF56F4FAF62222EF02053C2@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/13 12:11 PM, "Jiri Benc" <jbenc@redhat.com> wrote:

>On Tue, 19 Mar 2013 21:17:25 +0000, Vick, Matthew wrote:
>> Good catch on this, Jiri! I know the math works out the same, but I'd
>> prefer it if you changed the max_adj value to 999999999, since that is
>> technically what we can accept before we have any issues. If you
>>re-submit
>> with this change, I'll add my ACK and we can run it through our internal
>> testing. Thanks!
>
>But the real maximum value is actually 999999881, as anything higher
>than that would be capped to 999999881 by the driver. I don't think the
>driver should advertise higher max_adj than it is able to fulfill,
>otherwise there would be no need for the field.

I prefer 999999999 as it's something that looks slightly less "magic
number"-y (plus looks like the other devices in igb) and is still
technically something that can be passed down without error. Ultimately
not a big deal and I can understand your argument, so I'm okay putting my
personal preference aside on this one.
