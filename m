From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 20:12:25 +0200
Message-ID: <20060728181225.GF14627@postel.suug.ch>
References: <20060717155224.060020000@hp.com> <20060717155822.315389000@hp.com> <20060728112426.GE14627@postel.suug.ch> <44CA504C.6030207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57836 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161209AbWG1SMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:12:05 -0400
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <44CA504C.6030207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul Moore <paul.moore@hp.com> 2006-07-28 13:58
> I'm  a little confused by your comment, could you be a bit more
> specific?  Are you basing your comment strictly on the text above?  If
> so, the problem may be my poor excuse for documentation rather then my
> poor excuse for implementation :)
> 
> I am using the generic netlink interface, in what I believe to be a
> "correct" fashion - please correct me if I'm wrong.

The netlink bits are spread around all patches so I just quoted
on this comment. By adding functions like netlbl_align(),
netlbl_put_u8(), netlbl_put_hdr() writing a netlink header
etc. you are just duplicating the already existing interfaces
found in net/netlink.h and net/genetlink.h.
