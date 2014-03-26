From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 09:23:28 -0400
Message-ID: <5332D4D0.90805@mojatatu.com>
References: <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140325211945.GC15723@casper.infradead.org> <20140326072148.GB2869@minipsycho.orion> <5332B365.6050807@mojatatu.com> <5332B4A0.2070505@mojatatu.com> <20140326132017.GE2869@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Neil Horman <nhorman@tuxdriver.com>,
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:45412 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbaCZNXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 09:23:32 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so2470493qcx.7
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 06:23:32 -0700 (PDT)
In-Reply-To: <20140326132017.GE2869@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 09:20, Jiri Pirko wrote:

> I think that bonding (bonding driver or any of bonding driver interface)
> should have nothing to do with the switch chip capability of link aggregation.

I am probably missing something: that may work - but not well at the
asic level. I can see it would work on packets to/from cpu because
we can use software techniques.
But how would it work at the ASIC level without ability to lag
the ports?

cheers,
jamal
