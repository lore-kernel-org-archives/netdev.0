From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net 1/2] caif: remove wrong dev_net_set() call
Date: Tue, 27 Jan 2015 13:41:29 +0100
Message-ID: <874mrcwg3q.fsf@nemi.mork.no>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
	<1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
	<54C777D0.6090608@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	dmitry.tarnyagin@lockless.no, arvid.brodin@alten.se,
	alex.aring@gmail.com, linux-wpan@vger.kernel.org,
	Sjur =?utf-8?Q?Br?= =?utf-8?Q?=C3=A6ndeland?=
	<sjur.brandeland@stericsson.com>,
	Dmitry Tarnyagin <abi.dmitryt@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56107 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758801AbbA0Mlq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:41:46 -0500
In-Reply-To: <54C777D0.6090608@6wind.com> (Nicolas Dichtel's message of "Tue,
	27 Jan 2015 12:34:40 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

>> CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
>> CC: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
>
> I got a "Delivery Status Notification (Failure)" for Dmitry Tarnyagin
> (I took the email address from the MAINTAINERS file):
>
>   Delivery to the following recipient failed permanently:
>
>        dmitry.tarnyagin@lockless.no
>
>   Technical details of permanent failure:
>   Google tried to deliver your message, but it was rejected by the se=
rver for
>   the recipient domain lockless.no by mail.lockless.no. [46.29.221.38=
].
>
>   The error that the other server returned was:
>   550 5.1.1 <dmitry.tarnyagin@lockless.no>: Recipient address rejecte=
d: User
>   unknown in virtual mailbox table
>
> Any suggestions?


He used a gmail address in commit dd9dfb9f95e2 ("cfg80211: merge in
beacon ies of hidden bss.").  Probably by accident, but worth trying
anyway...

I guess the stericsson.com addresses could be failing silently now? Ref
http://stericsson.com/ . Or are they still routed to the named recepien=
ts?


Bj=C3=B8rn
