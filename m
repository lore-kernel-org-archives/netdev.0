From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net 1/3] openvswitch: vlan: remove wrong likely statement
Date: Tue, 11 Oct 2016 13:38:59 -0400
Message-ID: <20161011173859.GX25403@egarver>
References: <cover.1476111550.git.jbenc@redhat.com>
 <a4b63fa787569359d227beecbdbf9b023081cffc.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932531AbcJKRjB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 13:39:01 -0400
Content-Disposition: inline
In-Reply-To: <a4b63fa787569359d227beecbdbf9b023081cffc.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 05:02:42PM +0200, Jiri Benc wrote:
> This code is called whenever flow key is being extracted from the packet.
> The packet may be as likely vlan tagged as not.
> 
> Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Eric Garver <e@erig.me>
