From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user
 space
Date: Wed, 5 Aug 2015 16:39:15 +0200
Message-ID: <20150805143915.GA3530@pox.localdomain>
References: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
 <20150731080019.GB4738@pox.localdomain>
 <55BB9734.1010005@plumgrid.com>
 <CAEP_g=-7-PkYGdcigXC68nh+nCKHkr=9soYjcQsCx5rOkTQ90Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37861 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbHEOjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 10:39:18 -0400
Received: by wibhh20 with SMTP id hh20so27477997wib.0
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 07:39:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAEP_g=-7-PkYGdcigXC68nh+nCKHkr=9soYjcQsCx5rOkTQ90Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/15 at 02:14pm, Jesse Gross wrote:
> On Fri, Jul 31, 2015 at 8:41 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> > thanks. I think exposing collect_metadata for vxlan and in the future
> > for other tunnel types is the clean enough way, though the other
> > alternative would be to get rid of collect_metadata flag
> > from the kernel and do it when flowmode flag is set. Thoughts?
> 
> This seems like a good idea to me - I'm not sure that flow based
> tunnels are all that useful without metadata collection enabled and
> the fewer interfaces that we have to create for each tunnel type, the
> better.

The use case at hand where the flag is useful if someone is only
doing flow based TX which can be handy if the tunnel id remains
unused.
