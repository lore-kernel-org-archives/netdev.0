From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] sctp: fix a compile error in sctp.h
Date: Wed, 15 Aug 2012 12:53:23 -0700
Message-ID: <874no4c4p8.fsf@xmission.com>
References: <1345025891-5021-1-git-send-email-amwang@redhat.com>
	<20120815.034501.1424538455974526416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58392 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160Ab2HOTxb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 15:53:31 -0400
In-Reply-To: <20120815.034501.1424538455974526416.davem@davemloft.net> (David
	Miller's message of "Wed, 15 Aug 2012 03:45:01 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 15 Aug 2012 18:18:11 +0800
>
>> I got the following compile error:
>>=20
>> In file included from include/net/sctp/checksum.h:46:0,
>>                  from net/ipv4/netfilter/nf_nat_proto_sctp.c:14:
>> include/net/sctp/sctp.h: In function =E2=80=98sctp_dbg_objcnt_init=E2=
=80=99:
>> include/net/sctp/sctp.h:370:88: error: parameter name omitted
>> include/net/sctp/sctp.h: In function =E2=80=98sctp_dbg_objcnt_exit=E2=
=80=99:
>> include/net/sctp/sctp.h:371:88: error: parameter name omitted
>>=20
>> which is caused by
>>=20
>> 	commit 13d782f6b4fbbaf9d0380a9947deb45a9de46ae7
>> 	Author: Eric W. Biederman <ebiederm@xmission.com>
>> 	Date:   Mon Aug 6 08:45:15 2012 +0000
>>=20
>> 	    sctp: Make the proc files per network namespace.
>>=20
>> This patch could fix it.
>>=20
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> Applied thanks.
>
> I appended the SCTP debug objcnt procfs netns conversions by hand
> since Eric didn't handle it in his commit.
>
> Eric, please turn all relevant options both on and off when testing
> the build of your patches.  Thanks.

Grr. My apologies.  It looks like that one slipped by me this time :(

Eric
