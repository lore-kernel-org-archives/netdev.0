From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Sat, 23 Apr 2016 03:49:38 +0200
Message-ID: <20160423014938.GD32327@pox.localdomain>
References: <cover.1461346798.git.jbenc@redhat.com>
 <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34968 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbcDWBtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 21:49:41 -0400
Received: by mail-wm0-f47.google.com with SMTP id e201so34245433wme.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 18:49:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/16 at 07:44pm, Jiri Benc wrote:
> For ipgre interfaces in collect metadata mode, receive also traffic with
> encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
> out correctly. This allows to have mixed Ethernet + L3-only traffic on the
> same lwtunnel interface.
> 
> To keep backwards compatibility and prevent any surprises, gretap interfaces
> have priority in receiving packets with Ethernet headers.

I may be missing some context. Is anyone using this already or is this
preparing the stage for another user? It's not clear to me from the
commit message.
