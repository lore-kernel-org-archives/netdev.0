From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 17:33:57 -0400
Message-ID: <53349945.1000303@mojatatu.com>
References: <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org> <20140326112903.GG15723@casper.infradead.org> <20140326182122.GC31370@hmsreliant.think-freely.org> <CAGVrzcYNW0Z96mL-MecY=mte=+TcFn8k3eSY4pqi9h0N2jF7hw@mail.gmail.com> <53335838.3060409@mojatatu.com> <20140327152655.GA1358@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:54853 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756978AbaC0VeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 17:34:08 -0400
Received: by mail-ob0-f180.google.com with SMTP id wn1so4965517obc.39
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 14:34:08 -0700 (PDT)
In-Reply-To: <20140327152655.GA1358@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 11:26, Neil Horman wrote:

> You're absolutely correct - I am viewing this from a host based perspective.
> And I completely understand that offload is good in a middle box environment (I
> worked for embedded switch companies in a former life).  I'm looking at it from
> a host perspective because, as we've been discussing the wide range of devices
> covered here (from the small SOC switches used by owrt to the big enterprise
> switches), theres this middle ground thats seeing some consolodation here which
> I think we need to cover as well.  I'm referring to NICS that have an embedded
> switch in them that can (or soon will) preform lots of these flow based
> forwarding operations and actions.

Agreed - I think we need to capture those. The challenge there maybe how
to abstract some of those tables (example in VMDQ) and make it feel
like a L2 fdb.

cheers,
jamal
