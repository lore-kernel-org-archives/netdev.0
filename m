From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 1/2] include: add linked list implementation
 from kernel
Date: Wed, 23 Mar 2016 14:08:12 +0100
Message-ID: <20160323130812.GC1929@nanopsycho.orion>
References: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D41124DBA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yishaih@mellanox.com" <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	"eugenia@mellanox.com" <eugenia@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"hadarh@mellanox.com" <hadarh@mellanox.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kir
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38271 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbcCWNIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 09:08:16 -0400
Received: by mail-wm0-f41.google.com with SMTP id l68so23387824wml.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 06:08:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41124DBA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 23, 2016 at 01:22:22PM CET, David.Laight@ACULAB.COM wrote:
>From: Jiri Pirko
>> Sent: 22 March 2016 09:02
>> Rename hlist.h to list.h while adding it to be aligned with kernel
>...
>>  include/hlist.h |  56 ----------------------------
>>  include/list.h  | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>
>I'm not sure where this gets installed, but #include <list.h>
>is likely to give grief and find the wrong file.

It does not get installed anywhere.

>
>Even hlist.h seems a bit terse.
>
>	David
>
