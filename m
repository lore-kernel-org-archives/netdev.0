From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Does NetworkManager kill IPv6 connections?
Date: Thu, 04 Sep 2014 19:43:45 +0200
Message-ID: <5408A4D1.9050606@redhat.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174876CB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, dcbw@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbaIDRnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 13:43:51 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174876CB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Cc'ing Dan ]

On 09/04/2014 04:47 PM, David Laight wrote:
> I was running a overnight test that failed because an (almost idle) IPv6 connection
> unexpectedly disconnected.
> 30 seconds before the disconnect syslog contains (retyped):
>    NetworkManager[pid]: <info> policy set 'Wired connection 2' (eth0) as default for IPv6 routing and DNS.
> The same message appeared exactly 70 minutes earlier - with no ill effect.
> A second connection between the same pair if addresses (carrying a lot of traffic)
> was unaffected.
>
> Any idea what/why NetworkManager is doing?
> (Yes I know it is userspace, but it seems to be breaking the kernel....)
>
> The system is an ubuntu 13.04 desktop (3.8.0-19 kernel), that recent, but
> newer than the ones a lot of our customers use.
>
> I can rerun the test, but don't know what to look for.
> 'eth0' is the only ethernet interface in the system that is actually
> connected to a network.
>
> Some indications of where to look would be appreciated.
>
> 	David
