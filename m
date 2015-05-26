From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Tue, 26 May 2015 14:10:08 +0200
Message-ID: <556462A0.2020708@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com> <5562FFB0.40708@ahsoftware.de> <55631F22.90903@6wind.com> <55645097.5000509@ahsoftware.de>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36048 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbbEZOF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 10:05:26 -0400
Received: by wgbgq6 with SMTP id gq6so98316329wgb.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 07:05:25 -0700 (PDT)
In-Reply-To: <55645097.5000509@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/05/2015 12:53, Alexander Holler a =C3=A9crit :
> Am 25.05.2015 um 15:09 schrieb Nicolas Dichtel:
[snip]
>
> Hmm, sounds like we're talking in different rooms about the same thin=
g in regard
> to the dump. ;)
>
> I just wanted to explain why I think this series misses the (extended=
) dump
> which includes all interfaces (those of other namespaces too).
H=C3=A9h=C3=A9, I'm fully aware of the limitations, we move step by ste=
p but feel free to
send a patch ;-)
More seriously, I'm thinking to that problem but I did not start anythi=
ng right
now and I don't know when I will have time to do it.
If I understand well, you are saying that this missing part is blocker =
to use
the new socket option. I don't agree with this. Doing a dump in an anot=
her netns
is easy to do.

>
> How does one use NETLINK_LISTEN_ALL_NSID without beeing able to dump =
all the
> interfaces of namespaces your patch series might send messages for?
>
> The only way I currently see, is to start the listening part before a=
ny
> namespace is created. Doing so, it can fill it's internal structures =
with the
> RTM_NEWLINK messages (besides that missing one for lo). But how do yo=
u get these
> RTM_NEWLINK messages for already created namespaces and their interfa=
ces, if not
> by a dump?
I don't understand why dumping in another netns is a problem.


Regards,
Nicolas
