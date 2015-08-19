From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 06/13] route: move lwtunnel state to dst_entry
Date: Wed, 19 Aug 2015 18:38:31 +0200
Message-ID: <20150819163831.GF3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <cb74c3206e0747bd3b1efddd766bb9421aa06ebc.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36955 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbbHSQid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:38:33 -0400
Received: by wibhh20 with SMTP id hh20so13512198wib.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:38:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cb74c3206e0747bd3b1efddd766bb9421aa06ebc.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> Currently, the lwtunnel state resides in per-protocol data. This is
> a problem if we encapsulate ipv6 traffic in an ipv4 tunnel (or vice versa).
> The xmit function of the tunnel does not know whether the packet has been
> routed to it by ipv4 or ipv6, yet it needs the lwtstate data. Moving the
> lwtstate data to dst_entry makes such inter-protocol tunneling possible.
> 
> As a bonus, this brings a nice diffstat.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
