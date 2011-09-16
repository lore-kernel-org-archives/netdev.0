From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Fri, 16 Sep 2011 09:50:44 -0700
Message-ID: <1316191845.2201.5.camel@schen9-mobl>
References: <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
	 <1315364126.3400.64.camel@edumazet-laptop>
	 <20110916.193529.1252147879675316417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, zheng.z.yan@linux.intel.com,
	zheng.z.yan@intel.com, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, jirislaby@gmail.com, sedat.dilek@gmail.com,
	alex.shi@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24492 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925Ab1IPXuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 19:50:46 -0400
In-Reply-To: <20110916.193529.1252147879675316417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-16 at 19:35 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 07 Sep 2011 04:55:26 +0200
> 
> > Please David just revert 0856a304091b33a8e
> 
> Done.

Eric,

Can you re-spin a patch that incorporates your idea that we don't
add pid/credential references when we are not requesting credentials
in the socket. And probably another one that remove unnecessary
pid/credentials references in send/receive when we do use credentials?

Tim
