From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Thu, 17 Jul 2003 23:53:11 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030717.235311.94788744.yoshfuji@linux-ipv6.org>
References: <3F15E86F.2030707@us.ibm.com>
	<200307170038.EAA12945@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307170038.EAA12945@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200307170038.EAA12945@dub.inr.ac.ru> (at Thu, 17 Jul 2003 04:38:00 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> Actually, the original plan was to use ifli_family to query something
> or to direct a request to a specific interface on some netdevice.
> I wanted to reserve IFLI_PROTINFO attribute to encapsulate information
> private for specific family. It was not realized mostly because of absense
> of such information.
> 
> Maybe, you will want to resurrect this.

Ah, okay, I'm ok to reuse ifi_family in ifinfomsg{}.
e.g. if ifi_family == AF_INET6 (and/or AF_UNSPEC?), kernel sends 
per-interface IPv6 information.
  IFLA_INET6       provides if_flags (etc?)
  IFLA_INET6_CONF  provides cnf (without proc_dir_entry :-p)
  IFLA_INET6_STATS provides stats (XXX: missing entries in stats)
  IFLA_INET6_MCAST provides mc_XXX things
etc, etc.

sounds reasonable?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
