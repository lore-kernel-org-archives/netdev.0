From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] sctp: Namespacify checksum_disable
Date: Tue, 15 Oct 2013 09:38:18 +0800
Message-ID: <525C9C8A.7030603@windriver.com>
References: <1381739545-674-1-git-send-email-fan.du@windriver.com> <1170c5bd-54e0-4051-a280-ff6538a47614@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36762 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3JOBkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 21:40:18 -0400
In-Reply-To: <1170c5bd-54e0-4051-a280-ff6538a47614@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8814=E6=97=A5 22:08, Vlad Yasevich wrote:
>
> Fan Du<fan.du@windriver.com>  wrote:
>
>> >SCTP CRC32-C checksum computing and verifying should be
>> >namespace-sensible,
>> >as each, e.g. tenant instance might need different checksum
>> >configuration for
>> >its requirement. So this patch enhance SCTP with this feature.
>> >
>> >Signed-off-by: Fan Du<fan.du@windriver.com>
> NACK.  We don't want that setting to be sysctl configurable.  It is o=
nly useful in very limited circumstances and is not really for producti=
on/everyday use.
>
> In fact, I am going to send in a patch that makes this module paramet=
er read only in /sys.

Thanks for the background explanation, Vlad.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
