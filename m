From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Fri, 19 Mar 2004 15:52:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319.155214.101331883.yoshfuji@linux-ipv6.org>
References: <200403171130.30282.mashirle@us.ibm.com>
	<20040318220647.3dbb9c43.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, netdev@oss.sgi.com, xma@us.ibm.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040318220647.3dbb9c43.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040318220647.3dbb9c43.davem@redhat.com> (at Thu, 18 Mar 2004 22:06:47 -0800), "David S. Miller" <davem@redhat.com> says:

> On Wed, 17 Mar 2004 11:30:30 -0800
> Shirley Ma <mashirle@us.ibm.com> wrote:
> 
> > This patch is against Linux 2.6.4 kernel. It has been tested, 'ip' utility 
> > works fine. This patch is used by IPv6 MIBs.
> 
> Are we really going to support adding anycast/multicast addresses using
> RTM_NEW{MULTI,ANY}CAST rtmsgs?  If not, let's not add them.
> 
> Otherwise I like your patch.

I think we'd like to do so (for anycast at least).

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
