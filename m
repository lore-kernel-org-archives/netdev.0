From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Wed, 10 Sep 2008 19:30:52 +0200
Message-ID: <f4845fc0809101030u2bd4dec4jb478ecc65240ea74@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
	 <20080908234028.GF13048@verge.net.au>
	 <f4845fc0809090230h1cbc01ev45c6ab4bdba61955@mail.gmail.com>
	 <20080909113131.GA3605@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	"Vince Busam" <vbusam@google.com>, wensong@linux-vs.org
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:54004 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbYIJRbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 13:31:04 -0400
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id m8AHUsYf020983
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 18:30:54 +0100
Received: from yw-out-2324.google.com (ywj3.prod.google.com [10.192.10.3])
	by spaceape24.eur.corp.google.com with ESMTP id m8AHUrjA002609
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 10:30:53 -0700
Received: by yw-out-2324.google.com with SMTP id 3so518824ywj.47
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 10:30:53 -0700 (PDT)
In-Reply-To: <20080909113131.GA3605@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2008 at 1:31 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 09, 2008 at 11:30:29AM +0200, Julius Volz wrote:
>> Great, thanks! I have tested TCP+UDP, local+remote clients, v4+v6,
>> NAT+DSR+TUN in all combinations that are expected to be working and
>> found no problems.
>
> Thanks once again for your testing. I'll send a pull request to Dave in
> the morning.

Thanks very much!

(CC: Wensong)
I guess it would make sense to start hosting the new ipvsadm version
somewhere on http://www.linuxvirtualserver.org/ soon. It could still
be marked as unstable and saying, "If you intend to use the
experimental IPv6 support for IPVS introduced in kernel 2.6.XX, you
will need this new version of ipvsadm: ...". Also, we can then point
to it in the Kconfig help text in CONFIG_IP_VS_IPV6. What do you
think?

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
