From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 09:47:55 +0100
Message-ID: <1267606075.2997.1.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267599269.2839.84.camel@edumazet-laptop>
	 <1267601728.2370.47.camel@debian>
	 <1267603357.2839.105.camel@edumazet-laptop>
	 <1267604053.2370.102.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:55385 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab0CCIr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:47:59 -0500
Received: by bwz4 with SMTP id 4so837781bwz.28
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 00:47:58 -0800 (PST)
In-Reply-To: <1267604053.2370.102.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 16:14 +0800, Zhu Yi a =C3=A9crit :

> I want to provide a method for protocols to set its sock backlog limi=
t.
> For example, the sctp_rmem is 373500 (sysctl_sctp_rmem[1]) which is
> larger than (sysctl_rmem_default << 1). But I'm not very sure about t=
he
> actual required size. So I didn't make it in the sctp patch. What do =
you
> think?

I think this is not about bug fixes, but followup patches.

We should first address the bug asap, then do further refinements later=
=2E



