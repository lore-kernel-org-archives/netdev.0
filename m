From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/7] mpls: Add a sysctl to control the size of
 the mpls label table
Date: Thu, 5 Mar 2015 01:45:55 -0800
Message-ID: <CAMs_D1-Ohar0CbgaB08jM0iGcORJxx_B9Ta778nd4m5unT6wMg@mail.gmail.com>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<87egp5tvlz.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37503 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932389AbbCEJp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 04:45:56 -0500
Received: by wibhm9 with SMTP id hm9so13931235wib.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 01:45:55 -0800 (PST)
In-Reply-To: <87egp5tvlz.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 5:11 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> This sysctl gives two benefits.  By defaulting the table size to 0
> mpls even when compiled in and enabled defaults to not forwarding
> any packets.  This prevents unpleasant surprises for users.
>
> The other benefit is that as mpls labels are allocated locally a dense
> table a small dense label table may be used which saves memory and
> is extremely simple and efficient to implement.
>

The label space is often partitioned into multiple sets in MPLS and
used for different purposes - for example, LSP labels, VPN labels,
Segment labels. This in turn means that the table may no longer be
dense. A sysctl allowing min and max label that spans the sets of
labels may be useful. Or should the ILM be made a hash table?

> This sysctl allows userspace to choose the restrictions on the label
> table size userspace applications need to cope with.
>

Vivek
