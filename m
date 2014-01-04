From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH RFC 0/7] Generic UDP Encapsulation
Date: Sat, 4 Jan 2014 15:13:53 -0800
Message-ID: <CA+mtBx__0zfV-ageMPNXe_xJw1n2hCdCwW=_HBhb58c9SMXDyQ@mail.gmail.com>
References: <alpine.DEB.2.02.1401021400260.32181@tomh.mtv.corp.google.com>
	<20140104143338.246740e3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45309 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbaADXNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:13:54 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so16605064iec.23
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:13:53 -0800 (PST)
In-Reply-To: <20140104143338.246740e3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 4, 2014 at 2:33 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 2 Jan 2014 14:12:06 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
>
>> This patch series implements Generic UDP Encapsulation (GUE).
>> Intelligently encapsulating packets in UDP leverages device
>> support for UDP flows. The 5-tuple hash can be computed for UDP
>> to provide good ECMP, RSS, or link aggregation port selection.
>>
>> Generic UDP encapsulation refers to encapsulating packets of
>> arbitray IP protocols in UDP packets. Two flavors of GUE
>> are implemented in these patches:
>>
>> 1) Direct protocol encapsulation
>> 2) Encapsualtion in generic UDP encapsulation
>
> Is this a new wire protocol, or a simplification of existing
> tunnel code? It seems to be VXLAN without the VNI header.

It is a new protocol. See
http://tools.ietf.org/html/draft-herbert-gue-00. GUE is different from
VXLAN in that it includes a protocol type (L2, L3, L4 packets can be
encapsulated), header length and more flag bits (for extensibility),
and is not specific to the virtualization use case.
