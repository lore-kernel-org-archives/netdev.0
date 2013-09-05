From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from
 analyzers
Date: Thu, 5 Sep 2013 12:44:37 -0700
Message-ID: <20130905124437.6b3e14ad@nehalam.linuxnetplumber.net>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
	<20130905.144442.2085221662776542385.davem@davemloft.net>
	<20130905115755.7aec533c@nehalam.linuxnetplumber.net>
	<20130905.150341.1090416835512463609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, dborkmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:55171 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890Ab3IETok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:44:40 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so2332901pab.39
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 12:44:40 -0700 (PDT)
In-Reply-To: <20130905.150341.1090416835512463609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Sep 2013 15:03:41 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 5 Sep 2013 11:57:55 -0700
> 
> > If you want filtering, why not add BPF (sk_filter) support to this?
> 
> That's one idea.
> 
> But using sk_protocol is at least consistent with how AF_PACKET does
> things.

Why not both.
