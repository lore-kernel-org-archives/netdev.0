From: Andre Tomt <andre@tomt.net>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 2 Oct 2015 08:52:04 +0200
Message-ID: <560E2994.5020400@tomt.net>
References: <1443650383.13282.10.camel@daevel.fr>
 <560D1223.3070606@googlemail.com>
 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
 <560D1C5A.3050508@googlemail.com>
 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Holger_Hoffst=c3=a4tte?=
	<holger.hoffstaette@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01. okt. 2015 13:52, Eric Dumazet wrote:
> On Thu, Oct 1, 2015 at 4:43 AM, Holger Hoffst=C3=A4tte
> <holger.hoffstaette@googlemail.com> wrote:
>> On 10/01/15 13:29, Eric Dumazet wrote:
>
>>> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
>>> Author: Eric Dumazet <edumazet@google.com>
>>> Date:   Thu Aug 13 15:44:51 2015 -0700
>>>
>>>      inet: fix potential deadlock in reqsk_queue_unlink()
<snip>
>> Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
>> we speak. Let's hope that this fixes the lockups.
>>
>
> It definitely should help !
>
> David, since patch is not yet seen on
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
> could you please add it to your queue ?

Seems to fix it for me as well. 3 systems have been running varying=20
types of production-like loads with it for 14+ hours without hanging.
