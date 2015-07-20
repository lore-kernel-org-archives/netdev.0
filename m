From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Mon, 20 Jul 2015 13:49:28 +0200
Message-ID: <20150720114928.GA17423@pox.localdomain>
References: <cover.1437137396.git.tgraf@suug.ch>
 <f5cf9490a8f114416ec24e9e1de190d6640f25f0.1437137396.git.tgraf@suug.ch>
 <55A94C59.4080801@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	weichunc@plumgrid.com, netdev@vger.kernel.org, dev@openvswitch.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34353 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbbGTLtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 07:49:31 -0400
Received: by wibud3 with SMTP id ud3so85573573wib.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 04:49:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55A94C59.4080801@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/15 at 11:41am, Alexei Starovoitov wrote:
> On 7/17/15 5:55 AM, Thomas Graf wrote:
> >@@ -2373,6 +2470,12 @@ static void vxlan_setup(struct net_device *dev)
> >  	netif_keep_dst(dev);
> >  	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> >
> >+	/* If in flow based mode, keep the dst including encapsulation
> >+	 * instructions for vxlan_xmit().
> >+	 */
> >+	if (vxlan->flags & VXLAN_F_FLOW_BASED)
> >+		netif_keep_dst(dev);
> 
> hmm, isn't this done already few lines above? ;)

Good point, fixed ;)
