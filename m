From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: ipvs oops in 3.0-rc7
Date: Thu, 21 Jul 2011 21:37:29 +0800
Message-ID: <CA+v9cxbhpt3LSZ_m+OA_Kujt79mvDZ7VnGqjbbPQxS_gY6+pTA@mail.gmail.com>
References: <20110720205019.9dfa30c3.rdunlap@xenotime.net>
	<alpine.LFD.2.00.1107211202380.1660@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org,
	Simon Horman <horms@verge.net.au>,
	Wensong Zhang <wensong@linux-vs.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:35306 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab1GUNhb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 09:37:31 -0400
In-Reply-To: <alpine.LFD.2.00.1107211202380.1660@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/21 Julian Anastasov <ja@ssi.bg>:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Wed, 20 Jul 2011, Randy Dunlap wrote:
>
>> I'm seeing the following Oops in 3.0-rc7 on x86_64, just loading and=
 unloading
>> modules. =A0Any chance this is already fixed? =A0I can test current =
git, but I
>> wanted to ask first.
>>
>> Looks like it is on the second module load of ip_vs (i.e.,
>> modprobe ip_vs; rmmod ip_vs; modprobe ip_vs).
>
> =A0 =A0 =A0 =A0I think, this problem was fixed by this patch:
>
> http://www.spinics.net/lists/lvs-devel/msg02051.html
>
> =A0 =A0 =A0 =A0But it seems it was lost somewhere ...
>

That's great, SB. can help to apply it again, thanks.
