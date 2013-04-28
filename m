From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Sun, 28 Apr 2013 13:53:17 -0700
Message-ID: <517D8C3D.60504@gmail.com>
References: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com> <517A7F29.7070903@mojatatu.com> <517AA41C.4040205@intel.com> <517D32AE.503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:60590 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960Ab3D1UxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 16:53:23 -0400
Received: by mail-pd0-f180.google.com with SMTP id u10so3279993pdi.11
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 13:53:22 -0700 (PDT)
In-Reply-To: <517D32AE.503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2013 07:31 AM, Jamal Hadi Salim wrote:
> Hi Alex,
> 
> On 13-04-26 11:58 AM, Alexander Duyck wrote:
> 
>> Getting it to compile is kind of important since it was preventing me
>> from completing the build for iproute2 as I had another fix I needed to
>> test.
> 
> So i just went back and looked. I was under the impression the original
> patch from Hasan was not incorporated, it turns out it was (I just didnt
> get the usual "applied" email; ands unfortunately for some reason i
> showed up as the author instead of Hasan). It is the patch you are
> referring to.
> 
> Second - I did compile this on Debian squeeze which is iptables 1.4.8
> based; lucky, I still have that machine around, so i just verified again
> that the current git tree compiles fine there.
> So this could be a fedora specific issue.
> What does the generated Config file have for you?
> on squeeze:
> IPT_LIB_DIR:=/lib/xtables
> 

I just realized my patch description is incorrect.  I had called out
xtables_options_xfrm as the function I was fixing when it was actually
references to xtables_merge_options I was fixing in the patch.  From
what I can tell, all the way up to 1.4.10 xtables_merge_options only had
3 parameters in include/xtables.h.in.  It looks like things switch to
version 6 in 1.4.11 and then xtables_options_xfrm takes 4 parameters.

I will update the patch description and send out a new copy tomorrow.

Thanks,

Alex
