From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 16:32:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.163209.595697847.yoshfuji@linux-ipv6.org>
References: <20021031.124459.66300488.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210310908090.19356-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com,
   kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210310908090.19356-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210310908090.19356-100000@netcore.fi> (at Thu, 31 Oct 2002 09:25:01 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> I belive privacy extensions can be harmful for especially long-lived
> applications and lead to a false sense of security: they should not be
> enabled (by any definition of enabled) by default.

Temporary addresses are generated (on most links) but not used by default 
(latter is done by source address selection) by my patch.  
Set sysctl net.ipv6.conf.ethXX.use_tempaddr > 1 to use it by default.

(I have per-application setsockopt interface but it is not included 
 because patch for source address selection is not accepted at this moment.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
