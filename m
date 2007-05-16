From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Wed, 16 May 2007 17:51:01 -0300
Message-ID: <39e6f6c70705161351i249715ud7a4cc317d9677bc@mail.gmail.com>
References: <20070516145100.29877.0@janus.isnogud.escape.de>
	 <20070516145121.29877.2@janus.isnogud.escape.de>
	 <39e6f6c70705160935q66109a3ci414374544d99c78f@mail.gmail.com>
	 <ygfsl9wfunn.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Thomas Gleixner" <tglx@linutronix.de>,
	"Oliver Hartkopp" <oliver.hartkopp@volkswagen.de>
To: "Urs Thuermann" <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:45126 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758990AbXEPUvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 16:51:03 -0400
Received: by wr-out-0506.google.com with SMTP id 76so372027wra
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 13:51:02 -0700 (PDT)
In-Reply-To: <ygfsl9wfunn.fsf@janus.isnogud.escape.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 May 2007 21:14:20 +0200, Urs Thuermann <urs@isnogud.escape.de> wrote:
> "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net> writes:
>
> > Can can_ifindex be turned into a unsigned short? That way we would
> > have it nicely packed, avoiding this hole:
>
> Since dev->ifindex is int and we have many assignments between
> can_ifindex and dev->ifindex it would not make sense to define
> can_ifindex as a short int.  Also in user space, ifindex is int,
> e.g. in struct ifreq.  This would cause implicit truncating type casts
> from int to short int (some compilers warn about this, haven't tried
> GCC for a long time) or require many explicit type casts.

Quick answer, thank you.

- Arnaldo
