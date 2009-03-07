From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan:  Deterministic ingress packet delivery
Date: Sat, 07 Mar 2009 08:36:29 -0800
Message-ID: <49B2A28D.30502@candelatech.com>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>	<m1bpsellmv.fsf@fess.ebiederm.org> <49B15865.10103@candelatech.com> <m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56971 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbZCGQgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 11:36:35 -0500
In-Reply-To: <m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> >From 22d0a3e4ffa91f85c224d171ed7cc2d64a6dda00 Mon Sep 17 00:00:00 2001
> From: Eric Biederman <ebiederm@xmission.com>
> Date: Fri, 6 Mar 2009 09:16:30 -0800
> Subject: 
>
> Changing the mac address when a macvlan device is up will leave the
> device on the wrong hash chain making it impossible to receive
> packets.
>   
I see no problem with this, but Patrick knows the code better...

Might be nice to use a bigger hash some day, but can deal with that 
separately.

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


