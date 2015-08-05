From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] vxlan: combine VXLAN_FLOWBASED into
 VXLAN_COLLECT_METADATA
Date: Wed, 5 Aug 2015 16:42:42 +0200
Message-ID: <20150805144242.GB3530@pox.localdomain>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35594 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbHEOmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 10:42:45 -0400
Received: by wibxm9 with SMTP id xm9so211644067wib.0
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 07:42:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/15 at 10:51pm, Alexei Starovoitov wrote:
> IFLA_VXLAN_FLOWBASED is useless without IFLA_VXLAN_COLLECT_METADATA,
> so combine them into single IFLA_VXLAN_COLLECT_METADATA flag.
> 'flowbased' doesn't convey real meaning of the vxlan tunnel mode.
> This mode can be used by routing, tc+bpf and ovs.
> Only ovs is strictly flow based, so 'collect metadata' is a better
> name for this tunnel mode.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

I have no objection since a flag to enable tx only can be added again if
needed. As stated in the other thread, the tx only mode which is what
VXLAN was capable of doing so far is what motivated the split of flags.

Acked-by: Thomas Graf <tgraf@suug.ch>
