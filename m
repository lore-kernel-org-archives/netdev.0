From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [IPROUTE PATCH v2] iproute2: act_ipt fix xtables breakage on
 older versions.
Date: Wed, 01 May 2013 10:18:21 -0700
Message-ID: <51814E5D.5030505@intel.com>
References: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com> <517FC04E.30705@mojatatu.com> <517FEC48.80700@intel.com> <51811D06.2070800@mojatatu.com> <518124D3.8070800@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39527 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab3EARSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 13:18:22 -0400
In-Reply-To: <518124D3.8070800@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2013 07:21 AM, Jamal Hadi Salim wrote:
> On 13-05-01 09:47 AM, Jamal Hadi Salim wrote:
>> Hi Alex,
>>
>
>> So now i am wondering how the FSCK this thing even compiled.
>
> Mystery solved. Man, this idea of keeping up with the distros and
> iptables variants is a little insane.
> Debian's setup ends up using m_ipt.c for anything less than iptable
> 1.4.11. Kudos to the debian iproute maintainer.
> Fedora on the other hand seems to going to m_xt.c
> (This is why i asked for your Config earlier).
> In any case, your patch is correct. So i will go sign off on it;
> its just nobody else had to deal with that (or reported it).
>
> Thanks for your patience Alex.
>
> cheers,
> jamal
>

No problem.  Just glad to have that patch off of my backlog of things to
get upstream.

Thanks,

Alex
