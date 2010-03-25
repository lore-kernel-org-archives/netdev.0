From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] e1000e: export some settings using ethtool private flags
Date: Thu, 25 Mar 2010 10:52:05 -0700
Message-ID: <j2i97949e3e1003251052z49d59183p85a22589cd69d5eb@mail.gmail.com>
References: <20100227082305.GA18194@havoc.gtf.org> <EA929A9653AAE14F841771FB1DE5A1365FE4B3E5A7@rrsmsx501.amr.corp.intel.com>
	<4BAB9DB0.7020203@garzik.org> <EA929A9653AAE14F841771FB1DE5A1365FE4B3E600@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:28996 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab0CYRwe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:52:34 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [10.3.21.1])
	by smtp-out.google.com with ESMTP id o2PHqThD005723
	for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 10:52:30 -0700
Received: from ywh1 (ywh1.prod.google.com [10.192.8.1])
	by hpaq1.eem.corp.google.com with ESMTP id o2PHqRZe026271
	for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 18:52:28 +0100
Received: by ywh1 with SMTP id 1so3815095ywh.3
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 10:52:27 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4B3E600@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://lists.openwall.net/netdev/2007/08/10/114

On Thu, Mar 25, 2010 at 10:33 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
> Jeff Garzik wrote:
>> On 03/25/2010 01:16 PM, Tantilov, Emil S wrote:
>>> Jeff Garzik wrote:
>>>> The ethtool private flags interface exists to get/set
>>>> driver-specific settings at runtime, in a flexible manner.
>>>>
>>>> Use this facility to export a couple e1000e features, that were
>>>> previously only set at module initialization time.
>>>>
>>>> Signed-off-by: Jeff Garzik<jgarzik@redhat.com>
>>>> ---
>>>> =A0 drivers/net/e1000e/ethtool.c | =A0 27 ++++++++++++++++++++++++=
+++
>>>> =A0 1 file changed, 27 insertions(+)
>>>
>>> Jeff,
>>>
>>> What is the use case for the ethtool private flags?
>>
>> It is stated in the changelog above :) =A0It enables feature setting=
 at
>> setting, on an easy, per-network-interface basis, that were previous=
ly
>> only settable at module initialization (ie. load) time.
>>
>>
>>> At least I don't see an option in ethtool that would make use of
>>> them.
>>
>> This is added in a separate patch, since the above patch is the firs=
t
>> to make use of the private-flags ethtool mechanism.
>
> Can you point me to it? It would really help me with testing.
>
> Thanks,
> Emil
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
