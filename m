From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] macvlan/macvtap: guest/host cannot communicate when
 network cable is unplugged
Date: Fri, 31 Aug 2012 06:34:09 +0100
Message-ID: <CAJSP0QX3zOz-EXnHQyrxXfXBjEDi4-8sBR-rgQxFdg8wZtRisA@mail.gmail.com>
References: <503D486B.1030208@gmail.com>
	<CAJSP0QWV_RmEteRMUj4U2B9QRjGMkKL=AG3iyKyqEYiqGftFWg@mail.gmail.com>
	<503F58D0.2010003@gmail.com>
	<CAJSP0QXkHLKpo0kbnPu7L1zH5aL2XCPdmzi7+-xFctU7Pchyqw@mail.gmail.com>
	<503FEA05.6060202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: qemu-devel@nongnu.org, kaber@trash.net,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: ching <lsching17@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59204 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992Ab2HaFeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 01:34:11 -0400
Received: by lagy9 with SMTP id y9so2043770lag.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 22:34:10 -0700 (PDT)
In-Reply-To: <503FEA05.6060202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 30, 2012 at 11:32 PM, ching <lsching17@gmail.com> wrote:
>
>>> I also perform an additional test: the guests (macvtap bridge mode) CAN communicate each other no matter network cable is plugged or not.
>> Strange.  I thought the original problem was that the macvtap guests
>> cannot communicate with each other when the network cable is
>> unplugged?
>>
>> Hopefully someone else can help you, I'm not familiar enough with
>> macvlan/macvtap.
>>
>> Stefan
>>
>
> My word may be a little bit confusing, it should be
>
> I also perform an additional test: I created two qemu guests (macvtap bridge mode on eth0), they CAN communicate each other no matter network cable of the host is unplugged or not.
>
> and my problem is specified in the subject already: guest/host cannot communicate when network cable is unplugged
>
>
> if my configuration seems correct, i may file a kernel bugzilla and seek for their advice.

Yes.  If no one else responds then it's worth filing a bug.

Stefan
