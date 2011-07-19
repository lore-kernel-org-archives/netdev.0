From: =?UTF-8?B?SsOpcsO0bWUgUG91bGlu?= <jeromepoulin@gmail.com>
Subject: Re: ping6
Date: Mon, 18 Jul 2011 22:06:59 -0400
Message-ID: <CALJXSJpJmyLLDEs0aLxQ8-4r+mr6y9m+wuinQsxmn+1FNYUdLQ@mail.gmail.com>
References: <fa4b41e8992b983d77dc2b57c72431e7.squirrel@charon> <CALJXSJqwiW0b-uM0YzNnPG1V3sR3q9J4M9_hhufK+ZFWW=Gdrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: eric@certus.bz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59087 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029Ab1GSCHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 22:07:34 -0400
Received: by iwn6 with SMTP id 6so3639751iwn.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 19:07:34 -0700 (PDT)
In-Reply-To: <CALJXSJqwiW0b-uM0YzNnPG1V3sR3q9J4M9_hhufK+ZFWW=Gdrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2011 at 4:23 PM, <eric@certus.bz> wrote:
>
> I've found what I think is a bug in the ping6 tool. Without the -n option,
> it puts the hostname inside the parenthesis instead of the resolved ip

I guess this is on purpose as IPv6 has very long IP and hostnames
should be used when possible, also, it does not show the hostname you
typed but the resolved RDNS of the IP as in:

jerome@MobileCPU ~ $ ping6 www.google.ca
PING www.google.ca(iad04s01-in-x63.1e100.net) 56 data bytes
64 bytes from iad04s01-in-x63.1e100.net: icmp_seq=1 ttl=55 time=57.7 ms
