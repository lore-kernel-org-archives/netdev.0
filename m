From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: netstat and dual stack sockets
Date: Mon, 15 Jun 2015 23:36:54 +0200
Message-ID: <CAPh34mdX2YuqMVY8Adjnaa4CET2xaMJafQ2mLgck6sOo0Nq3xQ@mail.gmail.com>
References: <20150615205421.GA22616@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34385 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbFOVgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 17:36:54 -0400
Received: by oigx81 with SMTP id x81so9344216oig.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 14:36:54 -0700 (PDT)
In-Reply-To: <20150615205421.GA22616@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 June 2015 at 22:54, Phil Sutter <phil@nwl.cc> wrote:

> As I see it, a user has no way of detecting the listening socket in this
> address family: it does not show in /proc/net/{tcp,udp} nor do
> 'netstat', 'ss' or 'lsof' print any additional information about those
> sockets over pure IPv6 ones.

Probably a combination of IPV6_V6ONLY(1, 0) and IN6_IS_ADDR_V4MAPPED
fulfills all user requirements, ... so far. Your proposal is to hand
over sk->sk_ipv6only?

Hagen
