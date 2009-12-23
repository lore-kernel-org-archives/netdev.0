From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Can't parse ints with stroul()
Date: Wed, 23 Dec 2009 13:58:16 -0800
Message-ID: <9929d2390912231358o23ceb94qe3480723a60d44ec@mail.gmail.com>
References: <20091208173240.19917.99052.stgit@localhost.localdomain>
	 <9929d2390912091712g6d0543e9y170f21712b9efb7@mail.gmail.com>
	 <4B329127.8020002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:42019 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbZLWV6V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:58:21 -0500
Received: by pxi27 with SMTP id 27so3558090pxi.4
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 13:58:21 -0800 (PST)
In-Reply-To: <4B329127.8020002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2009 at 13:52, Jeff Garzik <jeff@garzik.org> wrote:
> On 12/09/2009 08:12 PM, Jeff Kirsher wrote:
>>
>> On Tue, Dec 8, 2009 at 09:32, Jeff Kirsher<jeffrey.t.kirsher@intel.c=
om>
>> =C2=A0wrote:
>>>
>>> From: PJ Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>>>
>>> A recent change to how int's were being parsed from the command
>>> line had them being read in with an unsigned int string operator.
>>> This didn't allow signed numbers from being read in correctly.
>>> This patch adds a get_uint() routine, and fixes the get_int()
>>> routine to read in signed values.
>>>
>>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.co=
m>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> ---
>>>
>>
>> Jeff G. - hold off on this patch. =C2=A0We have a version 2 in the w=
orks,
>> because we found if the sign bit was set on a uint, this would fail
>> parsing.
>
> Was version 2 ever posted? =C2=A0I never saw it...
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Jeff
>

Not yet, version 2 of the patch is in test right now.  I should have
it sent out either later tonight or tomorrow.

--=20
Cheers,
Jeff
