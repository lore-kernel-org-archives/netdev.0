From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 19:35:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.193541.89132835.davem@redhat.com>
References: <20020927.182833.66704359.davem@redhat.com>
	<200209280228.GAA02633@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280228.GAA02633@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Sat, 28 Sep 2002 06:28:29 +0400 (MSD)

   > Otherwise I have no problems with the patch, Alexey?
   
   I have... The implementation is bad. Source address must be retieved
   from route, not running this elephant function each packet.
   
This only runs at connect time, and when NULL fl->fl6_src is seen
by ip6_build_xmit() (this means RAW,UDP,ICMP which must make these
decisions anyways).

Is there really so much computation to be saved by moving this
to ipv6 route?
