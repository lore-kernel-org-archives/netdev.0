From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Fri, 3 Jan 2014 16:47:23 -0800
Message-ID: <20140103164723.6c514c2b@nehalam.linuxnetplumber.net>
References: <1388653054-4341-1-git-send-email-roy.qing.li@gmail.com>
	<slrnlccgj7.3uh.xiyou.wangcong@linux-6brj.site>
	<20140103.193253.2226162174184357030.davem@davemloft.net>
	<CAM_iQpUNgwUioWxDXe2DAhVFo0gvPudM1-_CXiNG2rZCnzLTag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49507 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbaADAr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:47:26 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so16422774pad.38
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:47:25 -0800 (PST)
In-Reply-To: <CAM_iQpUNgwUioWxDXe2DAhVFo0gvPudM1-_CXiNG2rZCnzLTag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Jan 2014 16:43:37 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, Jan 3, 2014 at 4:32 PM, David Miller <davem@davemloft.net> wrote:
> > From: Cong Wang <xiyou.wangcong@gmail.com>
> > Date: Fri, 3 Jan 2014 04:53:47 +0000 (UTC)
> >
> >> On Thu, 02 Jan 2014 at 08:57 GMT, roy.qing.li@gmail.com <roy.qing.li@gmail.com> wrote:
> >>> From: Li RongQing <roy.qing.li@gmail.com>
> >>>
> >>> They are same, so unify them as one, pcpu_tstats.
> >>> and move pcpu_tstat into netdevice.h
> >>>
> >>
> >> tstats means Tunnel STATS, right? So, it has to be
> >> in if_tunnel.h.
> >
> > They are being used in the bridging code now, did you read the
> > patch?
> >
> > So not really limited to just tunnels, and therefore they really do
> > belong somewhere generic like netdevice.h
> 
> I knew, my point is we should find a better name than "tstat".
> 
> >
> > This also means that since they are now an encapsulation thing we
> > should rename them to pcpu_encap_stats or similar, thanks.
> 
> Not sure "encap" makes sense for bridge too.

They are just the "busy" statistics from netdevice.
How about pcpu_sw_netstat?
