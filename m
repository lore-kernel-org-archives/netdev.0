From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Tue, 9 Apr 2013 15:15:35 +0200
Message-ID: <20130409131534.GB5132@netboy>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
 <20121213132916.GB10703@netboy.at.omicron.at>
 <50C9FEC4.5050804@onera.fr>
 <20121213181733.GA2312@netboy.at.omicron.at>
 <5163F0B1.7090309@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:52919 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759532Ab3DINPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:15:43 -0400
Received: by mail-bk0-f41.google.com with SMTP id i18so3643913bkv.0
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 06:15:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5163F0B1.7090309@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 12:42:57PM +0200, Paul Chavent wrote:
> 
> Would it be possible that the packet mmap maintainers give their
> opinion on this thread please ?

I was digging around, trying to understand whether libpcap can get HW
time stamps via the packet_mmap interface, and I found this.

 commit 614f60fa9d73a9e8fdff3df83381907fea7c5649
 Author: Scott McMillan <scott.a.mcmillan@intel.com>
 Date:   Wed Jun 2 05:53:56 2010 -0700

    packet_mmap: expose hw packet timestamps to network packet capture utilities

Maybe you could ask Scott for help?

[ It looks to me like that patch is kinda useless, since the user has
  no way to tell whether the time stamps are from HW or SW. ]

HTH,
Richard
