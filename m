From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 12:50:39 -0400
Message-ID: <CACP96tR_c3-nVEGhswm1qt1WGXPNzyXA61FCxPutCTPNomjy+g@mail.gmail.com>
References: <5425EAA6.7040302@gmail.com>
	<1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
	<54295971.2040402@gmail.com>
	<54298B66.8060807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsahern@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:63164 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbaI2Qum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:50:42 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so1560810lbi.9
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 09:50:40 -0700 (PDT)
In-Reply-To: <54298B66.8060807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 12:40 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 09/29/2014 06:06 AM, David Ahern wrote:

>
> We have implemented support for at least most of this (excepting duplicate IPs)
> using routing tables, rules, and (optionally, xorp as the router).
>

My undertanding of multiple routing-tables/rules was that they
are closer in semantics to switch/router ACLs than to VRFs, eg.,
one big difference is that an interface can belong to exactly one
VRF at a time, which is not mandated by multiple routing-tables/rules.

Was I mistaken?

--Sowmini
