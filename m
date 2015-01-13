From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Tue, 13 Jan 2015 01:04:18 +0000
Message-ID: <20150113010418.GC20387@casper.infradead.org>
References: <cover.1420756324.git.tgraf@suug.ch>
 <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
 <54B40661.9020408@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48690 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbbAMBEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:04:20 -0500
Content-Disposition: inline
In-Reply-To: <54B40661.9020408@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 06:37pm, Nicolas Dichtel wrote:
> >+	if (data[IFLA_VXLAN_EXTENSION])
> >+		configure_vxlan_exts(vxlan, data[IFLA_VXLAN_EXTENSION]);
> >+
> Can you also update vxlan_fill_info() so that these new attributes can be
> dumped via netlink?

Sure, will do.
