From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Tue, 24 Sep 2013 10:33:22 +0900
Message-ID: <20130924013322.GM25601@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
 <20130918220756.GA24919@verge.net.au>
 <CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
 <20130922053800.GA4890@verge.net.au>
 <CALnjE+o_bcNbU6kv2eUBaNS4tincV+BmrFyJtZZRTaMPMVv8gw@mail.gmail.com>
 <CAEP_g=_Di4yUzR0ka_Ma73DPKRoeCYW-ZZvQ=_n7OVDmpRKbTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49077 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3IXBdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 21:33:25 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_Di4yUzR0ka_Ma73DPKRoeCYW-ZZvQ=_n7OVDmpRKbTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 02:24:31PM -0700, Jesse Gross wrote:
> On Mon, Sep 23, 2013 at 12:47 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> > This patch does not work since vport-netdev does not include compat
> > gso header. after including gso.h it gives me compiler error.
> > Can you post combined patch with fixes?
> 
> I think it's probably because of this:
> 
> +#if 1 // LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
> +#define dev_queue_xmit rpl_dev_queue_xmit
> +#endif
> 
> But otherwise, I agree the approach is much nicer than what is currently there.

Sorry for letting that slip through.

I'll post a more complete patch after doing some more testing.
