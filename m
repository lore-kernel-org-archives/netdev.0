From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Tue, 18 Mar 2014 17:51:23 +0200
Message-ID: <CAF1J0HNOSKvRpjxN9+fs25mVDqo9wh==c-ZuS1i7CaWAnrCEgA@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<CAJZOPZLN0SmB7xcLXWOnC2GoDfGhJ5N-T1zA4S4Pg+ikqyFnig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:37671 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaCRPvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:51:24 -0400
Received: by mail-qc0-f171.google.com with SMTP id c9so2155491qcz.2
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:51:24 -0700 (PDT)
In-Reply-To: <CAJZOPZLN0SmB7xcLXWOnC2GoDfGhJ5N-T1zA4S4Pg+ikqyFnig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 5:10 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Mon, Mar 17, 2014 at 1:17 PM, Mike Rapoport
> <mike.rapoport@ravellosystems.com> wrote:
>> If the vxlan interface is created without group definition, there is a
>> panic on the first packet reception:
>>
>> $ ip link add dev vxlan0 type vxlan id 1
>> $ ip addr add dev vxlan0 10.0.0.1/24
>> $ ip link set up dev vxlan0
>>
>>   BUG: unable to handle kernel paging request at 0000000100000103
>>   IP: [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399
>
> Hi Mike,
>
> So this bug/fix is for 3.14 and also earlier kernels?

I think the bug was introduced by addition of ipv6 to vxlan, which was
merged in 3.12.

> Or.



-- 
Sincerely yours,
Mike.
