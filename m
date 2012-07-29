From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2] GRE over IPv6
Date: Sun, 29 Jul 2012 00:23:42 -0700
Message-ID: <878ve3114x.fsf@xmission.com>
References: <20120728113512.3ffd8248@comp1> <877gtn3akt.fsf@xmission.com>
	<20120729093127.53091c1d@comp1>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59542 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab2G2HXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 03:23:51 -0400
In-Reply-To: <20120729093127.53091c1d@comp1> (Dmitry Kozlov's message of "Sun,
	29 Jul 2012 09:31:27 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Kozlov <xeb@mail.ru> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> Why are you implementing an ioctl based instead of using netlink?
>> Last I looked using netlink to create and delete tunnels was more
>> flexible and the preferred method and the existing ioctl based methods
>> were simply being maintained for backwards compatibility.
> I have implemented both ioctl and netlink based.
> So if ioctl based is unnecessary it is not difficult to remove this
> part.
>
>> Also it appears that you have failed to include the all important
>> ip6_gre.c
> What do you mean ?

I mean quit simply your patch adds to the Makefile the line:
obj-$(CONFIG_IPV6_GRE) += ip6_gre.o

But that your patch does not include a file named ip6_gre.c

Also your patch description talks about ip6gre_tnl_link_config and
ip6gre_newlink but those functions do not exist in your patch.  I
presume those functions are implemented in the missing ip6_gre.c

So please read the patch you sent to the mailing list and figure
out which file or files are missing.

Eric
