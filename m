From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCHv2 08/10] rfkill: Use switch to demux userspace operations
Date: Tue, 8 Mar 2016 09:01:06 -0500
Message-ID: <CA+A7VXXd0SONVPi2BOokL13YevR0+hmFz4KE-U1MvXT0qqWN_A@mail.gmail.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-9-git-send-email-jprvita@endlessm.com> <20160226175925.GA9331@w1.fi>
 <CA+A7VXUY=qVDQ-OqT+QJK8haN6AFX4Br=OPXi-6RCxpvH3=QRg@mail.gmail.com>
 <20160229223918.GA32464@w1.fi> <1456839787.3926.20.camel@sipsolutions.net> <CA+A7VXWWQOti7pOre08QcXN9vgssQH3V1f6RjphaK0VwM27C7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <j@w1.fi>, "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CA+A7VXWWQOti7pOre08QcXN9vgssQH3V1f6RjphaK0VwM27C7g@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Johannes,

On 1 March 2016 at 11:15, Jo=C3=A3o Paulo Rechi Vita <jprvita@gmail.com=
> wrote:
> On 1 March 2016 at 08:43, Johannes Berg <johannes@sipsolutions.net> w=
rote:
>>
>> I'm fine with Jouni's change, preserving the original behaviour of
>> requiring TYPE_ALL or the correct type, but I'm tempted to simply
>> remove the type check entirely.
>>
>> Thoughts?
>>
>
> I think this patch should keep the original logic, as this is suppose=
d
> to be a refactor only. If we decide to remove the check, we should to
> it in a separate patch, to make it clear for someone looking at the
> history later.
>
> I'm fine with removing the type check (in a separate patch), but I
> don't see much gain in doing so.
>

I just saw you picked this patch with Jouni's fix, thanks!

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
