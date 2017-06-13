From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/10] bpf: xdp: Report bpf_prog ID in IFLA_XDP
Date: Mon, 12 Jun 2017 23:07:23 -0700
Message-ID: <20170612230723.0da6c696@cakuba.netronome.com>
References: <20170613010025.2983342-1-kafai@fb.com>
        <20170612182452.61b8a0a3@cakuba.netronome.com>
        <20170613053534.2afamabn6wkwka44@dhcp-172-26-110-210.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:5225 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752100AbdFMGHb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 02:07:31 -0400
In-Reply-To: <20170613053534.2afamabn6wkwka44@dhcp-172-26-110-210.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jun 2017 22:35:34 -0700, Martin KaFai Lau wrote:
> On Mon, Jun 12, 2017 at 06:26:02PM -0700, Jakub Kicinski wrote:
> > On Mon, 12 Jun 2017 18:00:15 -0700, Martin KaFai Lau wrote:  
> > > This is the first usage of the new bpf_prog ID.  It is for
> > > reporting the ID of a xdp_prog through netlink.
> > >
> > > It rides on the existing IFLA_XDP.  This patch adds IFLA_XDP_PROG_ID
> > > for the bpf_prog ID reporting.
> > >
> > > It starts with changing the generic_xdp first.  After that,
> > > the hardware driver is changed one by one.  The final patch
> > > removes the prog_attached from 'struct netdev_xdp' because
> > > prog_id > 0 implies the presence of xdp_prog.  
> >
> > Daniel made the XDP_ATTACHED an enum to be able to extend it with other
> > modes.  I would appreciate if you didn't remove the member since I have
> > this waiting in my tree:  
> I see. I will keep prog_attached then.

Thanks!
