From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] USAGI IPsec
Date: Sat, 12 Oct 2002 22:43:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021012.224318.94555090.davem@redhat.com>
References: <20021012111759.GA10104@outpost.ds9a.nl>
	<20021012.044137.42774593.davem@redhat.com>
	<20021012121650.GA10827@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl
In-Reply-To: <20021012121650.GA10827@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: bert hubert <ahu@ds9a.nl>
   Date: Sat, 12 Oct 2002 14:16:50 +0200

   Some people on #lartc were wondering about the use of a route cache if there
   is only one route. It was reported that a single default route on a system
   that talks to many destinations would lead to a huge route cache, which is
   probably not more efficient than looking up the simple route.
   
   Would this 'small efficient flow cache' also solve this problem?
   
I contend there is no "problem".  Routing cache entries are
garbage collected, and even this can be tuned via sysctl.
