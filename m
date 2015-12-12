From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Sat, 12 Dec 2015 09:24:42 -0800
Message-ID: <CALx6S35aSWZnxJstSzkjRHXOrb5Y-1B_5qwnbx-naR3LJ0B_8A@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
	<CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
	<566864C0.6020204@solarflare.com>
	<CALx6S35UUmt+f4c_5Dh=8qvKBqtO7F5j_RqhXs01ONhj4HChKw@mail.gmail.com>
	<20151212164137.GG19608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:32793 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbbLLRYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 12:24:42 -0500
Received: by mail-ig0-f170.google.com with SMTP id mv3so59134075igc.0
        for <netdev@vger.kernel.org>; Sat, 12 Dec 2015 09:24:42 -0800 (PST)
In-Reply-To: <20151212164137.GG19608@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 12, 2015 at 8:41 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (12/11/15 15:50), Tom Herbert wrote:
>> layers of encapsulation. For example, suppose send a UDP packet in
>> VXLAN in VXLAN, where packet looks like:
>> IP|UDP|VXLAN|Eth|IP|UDP|VXLAN|Eth|IP|UDP. I believe the kernel can set
>
> Without detracting from the fact that you have probably found a bug
> for checksumming here..
>
> if you have multiple encapsulations above (vxlan over vxlan?)
> I think lot of other things like pmtu may also be broken?  (Each
> encaps layer lowers the actual application mtu till the thing starts
> to get absurd)
>
PMTU is going to be a headache with any encapsulation, multiple layers
just makes the headache worse. This is one of the reasons why ILA is
better for network virtualization-- no PMTU issue since there is no
encapsulation being done.

> --Sowmini
>
