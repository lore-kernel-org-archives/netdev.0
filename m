From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 19:55:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.195507.87349906.davem@redhat.com>
References: <20020927.193541.89132835.davem@redhat.com>
	<200209280258.GAA02712@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280258.GAA02712@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Sat, 28 Sep 2002 06:58:22 +0400 (MSD)

   > This only runs at connect time
   
   ... and also at ip6_build_xmit(). Connected dgram sockets are marginal.

I said UDP/RAW.  At least believe that I am this smart :-)

Point is that current function is not tiny either, so improvement you
suggest applies both to current code and code after Yoshi's change.
