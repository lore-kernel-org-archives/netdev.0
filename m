From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/4] ip_tunnels: record IP version in tunnel info
Date: Fri, 28 Aug 2015 09:33:26 -0700
Message-ID: <20150828163325.GB10425@Alexeis-MBP-2.westell.com>
References: <cover.1440771116.git.jbenc@redhat.com>
 <224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33818 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbbH1Qd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 12:33:27 -0400
Received: by pabzx8 with SMTP id zx8so67742322pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 09:33:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 04:27:26PM +0200, Jiri Benc wrote:
> There's currently nothing preventing directing packets with IPv6
> encapsulation data to IPv4 tunnels (and vice versa). If this happens,
> IPv6 addresses are incorrectly interpreted as IPv4 ones.
> 
> Track whether the given ip_tunnel_key contains IPv4 or IPv6 data. Store this
> in ip_tunnel_info. Reject packets at appropriate places if they are supposed
> to be encapsulated into an incompatible protocol.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
