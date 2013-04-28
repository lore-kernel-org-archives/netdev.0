From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Sun, 28 Apr 2013 10:31:10 -0400
Message-ID: <517D32AE.503@mojatatu.com>
References: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com> <517A7F29.7070903@mojatatu.com> <517AA41C.4040205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:48058 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3D1ObP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 10:31:15 -0400
Received: by mail-ia0-f173.google.com with SMTP id 21so1545538iay.32
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 07:31:14 -0700 (PDT)
In-Reply-To: <517AA41C.4040205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On 13-04-26 11:58 AM, Alexander Duyck wrote:

> Getting it to compile is kind of important since it was preventing me
> from completing the build for iproute2 as I had another fix I needed to
> test.

So i just went back and looked. I was under the impression the original
patch from Hasan was not incorporated, it turns out it was (I just didnt
get the usual "applied" email; ands unfortunately for some reason i
showed up as the author instead of Hasan). It is the patch you are 
referring to.

Second - I did compile this on Debian squeeze which is iptables 1.4.8
based; lucky, I still have that machine around, so i just verified again
that the current git tree compiles fine there.
So this could be a fedora specific issue.
What does the generated Config file have for you?
on squeeze:
IPT_LIB_DIR:=/lib/xtables

>
> If you have some test case you want me to run just let me know.  All I
> did here is revert the changes that I believe were made incorrectly for
> versions prior to 1.4.10 in "iproute2: act_ipt fix xtables breakage".
> It states it was fixing it for versions starting in 1.4.10 which I am
> assuming is the XTABLES_VERSION_CODE >= 6 case so it should not have
> modified the 3 parameter case for versions prior to 6 which is what I
> corrected.
>

Are you sure about that? Please double check again, i see 4 parameters.
Having said that the mystery and breakages may have to do with the way
the different distros package iptables.

cheers,
jamal
