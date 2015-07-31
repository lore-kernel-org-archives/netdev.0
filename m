From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user
 space
Date: Fri, 31 Jul 2015 10:00:19 +0200
Message-ID: <20150731080019.GB4738@pox.localdomain>
References: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36173 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbGaIAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 04:00:22 -0400
Received: by wicgj17 with SMTP id gj17so6233890wic.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 01:00:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/15 at 08:10pm, Alexei Starovoitov wrote:
> Two vxlan driver flags FLOWBASED and COLLECT_METADATA need to be set to
> make use of its new flow mode. The former already exposed. Expose the latter.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Since you are analyzing the program when you load it. Could you call
ip_tunnel_need_metadata() when we load a program which accesses
the new metadata field and ip_tunnel_unneed_metadata() when you unload
it? This would hide the need to set this flag from the user. The con
is that it enables metadata on all net_devices.

I'm also fine with exposing this flag to the user though. I'll leave it
up to you so feel free to add my ack if you want to go this route.

Acked-by: Thomas Graf <tgraf@suug.ch>
