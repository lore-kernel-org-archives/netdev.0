From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi- and broadcasts
Date: Mon, 15 Apr 2013 09:23:59 +0300
Message-ID: <CAF1J0HNT0W2HcopQrRarrGBcryjH-wVX55sm7V+L-evi64xGww@mail.gmail.com>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20130414.153950.1876060927096209566.davem@davemloft.net>
	<CAF1J0HMoSY4b4RWDPW3yRmXovBcot_1UMo4QJkbg43KJxTWPkg@mail.gmail.com>
	<20130415.014530.1175856229390286987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:35101 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751523Ab3DOGYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 02:24:02 -0400
Received: by mail-ob0-f197.google.com with SMTP id ef5so26972201obb.4
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 23:24:00 -0700 (PDT)
In-Reply-To: <20130415.014530.1175856229390286987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 8:45 AM, David Miller <davem@davemloft.net> wrote:
> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
> Date: Mon, 15 Apr 2013 08:31:15 +0300
>
>> On Sun, Apr 14, 2013 at 10:39 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
>>> Date: Sun, 14 Apr 2013 12:21:51 +0300
>>>
>>>> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
>>>> and therefore will be sent out bypassing encapsulation. This breaks
>>>> delivery of packets sent to the vxlan multicast group.
>>>> Disabling encapsulation bypass for multicasts and broadcasts fixes the
>>>> issue.
>>>>
>>>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>>>
>>> This still won't handle the case of encapsulations occuring in different
>>> namespaces or virtual machines.
>>>
>>> I really want this fixed correctly.
>>
>> I'm sorry, but I don't quite follow you. The patch does not aim to
>> reduce the amount of encapsulation. On the contrary, it prevents some
>> packets from being encapsulated when they should not be...
>
> I'm saying you need to make sure the bypass is avoided in these
> situations as well.

Ok, I see, thanks.

> There is an ongoing discussion about this on the list between Cong
> Wang and the author of the bypass changes.

Yes, I'm following that discussion.

-- 
Sincerely yours,
Mike.
