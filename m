From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] packet: Deliver VLAN TPID to userspace
Date: Tue, 22 Oct 2013 15:41:10 -0700
Message-ID: <20131022154110.518282ba@nehalam.linuxnetplumber.net>
References: <87a9i6jymc.wl%atzm@stratosphere.co.jp>
	<20131018105655.2cdc628e@nehalam.linuxnetplumber.net>
	<87k3h9hjen.wl%atzm@stratosphere.co.jp>
	<1382347494.25689.8.camel@deadeye.wl.decadent.org.uk>
	<87txgaj9nk.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, <netdev@vger.kernel.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33357 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab3JVWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 18:41:38 -0400
Received: by mail-pd0-f180.google.com with SMTP id p10so7451552pdj.25
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 15:41:38 -0700 (PDT)
In-Reply-To: <87txgaj9nk.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Oct 2013 11:56:31 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> Hmm...  I think TPACKET{,2,3}_HDRLEN should not be removed without
> careful considerations.  Because some userspace programs (e.g libpcap)
> are using them in order to check mmap ability of the kernel...


That's bad because it means the library then depends on the headers
of the machine it was built on, not the machine it is running on. I often
build software on boxes where /usr/include version of kernel headers is out dated.
