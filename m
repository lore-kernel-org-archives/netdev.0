From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH v2] iproute2: act_ipt fix xtables breakage on
 older versions.
Date: Wed, 01 May 2013 09:47:50 -0400
Message-ID: <51811D06.2070800@mojatatu.com>
References: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com> <517FC04E.30705@mojatatu.com> <517FEC48.80700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:43087 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab3EANr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 09:47:59 -0400
Received: by mail-ia0-f177.google.com with SMTP id y26so1381876iab.36
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 06:47:58 -0700 (PDT)
In-Reply-To: <517FEC48.80700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On 13-04-30 12:07 PM, Alexander Duyck wrote:
> On 04/30/2013 05:59 AM, Jamal Hadi Salim wrote:


>
> In the git tree it is obvious that xtables_merge_options only takes 3
> parameters.  It is not until v1.4.11 which is XTABLES_VERSION_CODE == 6
> that we see xtables_merge_options take 4 parameters.
>

I apologize, you are correct. So whats incorporated now is wrong
but compiles fine on Debian.
So now i am wondering how the FSCK this thing even compiled.
I am going to test your patch on Debian squeeze, with iptables 1.4.8
(where the current code compiles just fine) and will ack it if all is
good

cheers,
jamal
