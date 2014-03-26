From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 17:36:52 -0400
Message-ID: <53334874.8000004@mojatatu.com>
References: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org> <20140326112903.GG15723@casper.infradead.org> <20140326152215.GB12372@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:61529 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257AbaCZVgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:36:55 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so1069142igc.2
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 14:36:54 -0700 (PDT)
In-Reply-To: <20140326152215.GB12372@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 11:22, John W. Linville wrote:

> This part makes sense to me -- use the hardware forwarding offloads if
> they are available, but fall back to software for sake of flexibility.
> It gives the admin enough rope to shoot himself in the foot...
>

This should be left up to policy. Maybe a sysctl? Example:
I should be able to choose whether i want to _only_
use the L3 table in hardware and not in software for certain
traffic which may require lower latency.

cheers,
jamal
