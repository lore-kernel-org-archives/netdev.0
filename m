From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 2 Oct 2015 09:17:16 +0200
Message-ID: <560E2F7C.4040102@googlemail.com>
References: <1443650383.13282.10.camel@daevel.fr>
 <560D1223.3070606@googlemail.com>
 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
 <560D1C5A.3050508@googlemail.com>
 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
 <560E2994.5020400@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Andre Tomt <andre@tomt.net>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.68.134.40.188.clients.your-server.de ([188.40.134.68]:49532
	"EHLO mail02.iobjects.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbJBHRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 03:17:19 -0400
In-Reply-To: <560E2994.5020400@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/15 08:52, Andre Tomt wrote:
> On 01. okt. 2015 13:52, Eric Dumazet wrote:
>> On Thu, Oct 1, 2015 at 4:43 AM, Holger Hoffst=C3=A4tte
>> <holger.hoffstaette@googlemail.com> wrote:
>>> On 10/01/15 13:29, Eric Dumazet wrote:
>>
>>>> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
>>>> Author: Eric Dumazet <edumazet@google.com>
>>>> Date:   Thu Aug 13 15:44:51 2015 -0700
>>>>
>>>>      inet: fix potential deadlock in reqsk_queue_unlink()
> <snip>
>>> Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
>>> we speak. Let's hope that this fixes the lockups.
>>>
>>
>> It definitely should help !
>>
>> David, since patch is not yet seen on
>> http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
>> could you please add it to your queue ?
>=20
> Seems to fix it for me as well. 3 systems have been running varying
> types of production-like loads with it for 14+ hours without hanging.

Just got up, and yes - my systems survived the night as well, no issues=
=2E

Greg, any chance you can drop this into the pending 4.1.10? Otherwise p=
eople
will get another broken release.

cheers
Holger
