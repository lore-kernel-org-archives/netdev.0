From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next] geneve: fix fill_info when using
 collect_metadata
Date: Wed, 24 May 2017 15:58:20 -0400
Message-ID: <20170524195820.GE2211@dev-rhel7>
References: <20170523223727.15307-1-e@erig.me>
 <CAOrHB_CqAAWpHLuc+apQHbhL6SUS9bcKq3wW_TxbtWEWcgZrSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030292AbdEXT6X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 15:58:23 -0400
Content-Disposition: inline
In-Reply-To: <CAOrHB_CqAAWpHLuc+apQHbhL6SUS9bcKq3wW_TxbtWEWcgZrSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 12:20:36PM -0700, Pravin Shelar wrote:
> On Tue, May 23, 2017 at 3:37 PM, Eric Garver <e@erig.me> wrote:
> > Since 9b4437a5b870 ("geneve: Unify LWT and netdev handling.") fill_info
> > does not return UDP_ZERO_CSUM6_RX when using COLLECT_METADATA. This is
> > because it uses ip_tunnel_info_af() with the device level info, which is
> > not valid for COLLECT_METADATA.
> >
> > Fix by checking for the presence of the actual sockets.
> >
> > Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> > Signed-off-by: Eric Garver <e@erig.me>
> Thanks for the patch.
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> 
> 
> I noticed that the MTU and encal_len calculation in geneve_configure()
> also needs to be fixed for collect metadata case. Can you send patch
> to fix it?

Ah, yes. I'll take a look at those as well.

Eric.
