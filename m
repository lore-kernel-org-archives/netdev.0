From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 2/5] GSO: Add GSO type for fixed IPv4 ID
Date: Fri, 8 Apr 2016 15:12:22 -0700
Message-ID: <CAKgT0Ud-m1i0n1Dnbagpkii8jDYb-Wq43UQi+Dvv6b585jcJnQ@mail.gmail.com>
References: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
	<20160408203318.12838.59720.stgit@ahduyck-xeon-server>
	<CAEh+42j21N+3ScmR9D9P3esgUL-G0kWxNT1x2zfGi_9M-bPKzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33364 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131AbcDHWMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:12:23 -0400
Received: by mail-ig0-f182.google.com with SMTP id kb1so45617058igb.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 15:12:23 -0700 (PDT)
In-Reply-To: <CAEh+42j21N+3ScmR9D9P3esgUL-G0kWxNT1x2zfGi_9M-bPKzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 2:41 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Apr 8, 2016 at 5:33 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch adds support for TSO using IPv4 headers with a fixed IP ID
>> field.  This is meant to allow us to do a lossless GRO in the case of TCP
>> flows that use a fixed IP ID such as those that convert IPv6 header to IPv4
>> headers.
>>
>> In addition I am adding a feature that for now I am referring to TSO with
>> IP ID mangling.  Basically when this flag is enabled the device has the
>> option to either output the flow with incrementing IP IDs or with a fixed
>> IP ID regardless of what the original IP ID ordering was.  This is useful
>> in cases where the DF bit is set and we do not care if the original IP ID
>> value is maintained.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> I think SKB_GSO_TCP_FIXEDID would also need to be added to the list of
> enumerated OK GSO types for MPLS GSO.

I'll have that fixed for v2.

- Alex
