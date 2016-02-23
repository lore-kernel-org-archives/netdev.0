From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Tue, 23 Feb 2016 10:32:32 -0800
Message-ID: <CALx6S34_HnMqftJ7hUTzQChsA=Hi9RzkNTr=GJ4bNnyNUsaA6g@mail.gmail.com>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
	<CALx6S37p8eV-gURM0C8hP=G7XLt+=FFwV9HNF3z_FdciKxLf0A@mail.gmail.com>
	<20160223.132617.860625990168941692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Edward Cree <ecree@solarflare.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35776 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878AbcBWScd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:32:33 -0500
Received: by mail-ig0-f174.google.com with SMTP id hb3so105030625igb.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 10:32:33 -0800 (PST)
In-Reply-To: <20160223.132617.860625990168941692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 10:26 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 23 Feb 2016 09:42:00 -0800
>
>> Why not just fix the stack to conform to RFC6864? As Edward pointed
>> out we lose the actual IP ID's in GRO anyway, so attempts to set them
>> in GSO may be wildly incorrect from the source point of view-- even in
>> that case were probably better off changing the IP identifier to zero
>> (okay since we're already breaking the E2E model anyway :-) ).
>
> Tom, you can't, you'll break TCP header compression schemes which
> expect a monotonically increasing IP ID value.
>
> We tried setting the IP ID to zero for frames with DF set, it broke
> things.

All the more reason to move to IPv6 ;-)
