From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v2] ipv6: Use inbound ifaddr as source addresses for
 ICMPv6 errors
Date: Sun, 28 Aug 2016 19:18:00 +0200
Message-ID: <20160828171800.gtdo764pvoyhgim4@alphalink.fr>
References: <20160828033406.11269-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:56185 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755394AbcH1RSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 13:18:04 -0400
Content-Disposition: inline
In-Reply-To: <20160828033406.11269-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 11:34:06AM +0800, Eli Cooper wrote:
> According to RFC 1885 2.2(c), the source address of ICMPv6
> errors in response to forwarded packets should be set to the
> unicast address of the forwarding interface in order to be helpful
> in diagnosis.
> 
FWIW, this behaviour has been deprecated ten years ago by RFC 4443:
"The address SHOULD be chosen according to the rules that would be used
 to select the source address for any other packet originated by the
 node, given the destination address of the packet."

The door is left open for other address selection algorithms but, IMHO,
changing kernel's behaviour is better justified by real use cases
than by obsolete RFCs.
