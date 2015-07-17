From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Fri, 17 Jul 2015 11:41:29 -0700
Message-ID: <55A94C59.4080801@plumgrid.com>
References: <cover.1437137396.git.tgraf@suug.ch>
 <f5cf9490a8f114416ec24e9e1de190d6640f25f0.1437137396.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>, roopa@cumulusnetworks.com,
	rshearma@brocade.com, ebiederm@xmission.com,
	hannes@stressinduktion.org, pshelar@nicira.com, jesse@nicira.com,
	davem@davemloft.net, daniel@iogearbox.net, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36264 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbGQSld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 14:41:33 -0400
Received: by pdjr16 with SMTP id r16so66583172pdj.3
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 11:41:33 -0700 (PDT)
In-Reply-To: <f5cf9490a8f114416ec24e9e1de190d6640f25f0.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/15 5:55 AM, Thomas Graf wrote:
> @@ -2373,6 +2470,12 @@ static void vxlan_setup(struct net_device *dev)
>   	netif_keep_dst(dev);
>   	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
>
> +	/* If in flow based mode, keep the dst including encapsulation
> +	 * instructions for vxlan_xmit().
> +	 */
> +	if (vxlan->flags & VXLAN_F_FLOW_BASED)
> +		netif_keep_dst(dev);

hmm, isn't this done already few lines above? ;)
