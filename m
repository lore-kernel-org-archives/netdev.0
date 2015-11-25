From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Wed, 25 Nov 2015 05:49:32 -0800
Message-ID: <1448459372.22599.324.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564F3D3D.7050004@axis.com>
	 <1448043414.22599.287.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5655ADC7.3040606@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33948 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbbKYNte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 08:49:34 -0500
Received: by padhx2 with SMTP id hx2so58437218pad.1
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 05:49:34 -0800 (PST)
In-Reply-To: <5655ADC7.3040606@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 13:47 +0100, Niklas Cassel wrote:

> (SO_MAX_PACING_RATE would require modifying a lot of different user-space
> programs, so that is not really an option :( )

You can set a max rate on the packet scheduler itself, for all flows.

tc qdisc replace dev eth0 root fq maxrate 30Mbit
