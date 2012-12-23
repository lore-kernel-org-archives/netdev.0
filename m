From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 15:36:59 +0100
Message-ID: <CA+icZUXyBU301ZsKhhiHEsbpxX8gikhktRWFH4x_MSLc8M1eRA@mail.gmail.com>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
	<20121223114213.GB8386@liondog.tnic>
	<CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
	<CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
	<CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com>
	<CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
	<CA+icZUV4WEu6xp=-TyHH2z4Zcz8g0iHY2ZVk-jBJNt1azcXa2A@mail.gmail.com>
	<CAM_iQpU5VLGOAcZ=RfF8VqpRNTy7rueVpm=+U0Zy5SoAYk4THw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Borislav Petkov <bp@alien8.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:47761 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab2LWOhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 09:37:00 -0500
In-Reply-To: <CAM_iQpU5VLGOAcZ=RfF8VqpRNTy7rueVpm=+U0Zy5SoAYk4THw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2012 at 3:25 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Dec 23, 2012 at 10:14 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>
>> [ CCing Eric ]
>>
>> YES, thie fixes my problem.
>> But your patch was somehow malformed, so I attached mine.
>>
>
> Thanks for testing!
>
> I knew it as I replied in wed Gmail. :) I will send a normal patch
> with your Reported-by and Tested-by.

/o\ for your quick reply and patch!

Just as a sidenote:
The mentioned MEI patch [1] did also fix the ugly locking on
soft-reboot (for people who are affected and know about GIYF) :-).
Good I am doing a (filesystem) sync before reboots.

I did not much testing, but for a -rc1 release this looks now fine to me.

- Sedat -

[1] http://marc.info/?l=linux-kernel&m=135612627527193&w=2
