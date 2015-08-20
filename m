From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel metadata
 via lightweight tunnel
Date: Thu, 20 Aug 2015 11:29:06 +0900
Message-ID: <55D53B72.70403@miraclelinux.com>
References: <cover.1439978875.git.jbenc@redhat.com>	<0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>	<55D457B1.2080105@miraclelinux.com>	<20150819122034.5d904d8b@griffin>	<55D45A0A.7010100@miraclelinux.com> <20150819123151.3802e8f3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:32867 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbHTC3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 22:29:11 -0400
Received: by pdrh1 with SMTP id h1so8421543pdr.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 19:29:10 -0700 (PDT)
In-Reply-To: <20150819123151.3802e8f3@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc wrote:
> On Wed, 19 Aug 2015 19:27:22 +0900, YOSHIFUJI Hideaki wrote:
>>> You're right generally. But this one should be okay and I did this
>>> deliberately: the patch adding LWTUNNEL_ENCAP_ILA was merged two days
>>> ago, is in net-next only, is not used by anything in user space yet.
>>> And I think it's better to have LWTUNNEL_ENCAP_IP and
>>> LWTUNNEL_ENCAP_IP6 without anything in between.
>>
>> I do think you should have some descriptions.
> 
> Sorry, I meant to put this into the description but forget to add it
> after the rebase on top of ILA (as the patchset conflicted with the ILA
> work and was developed in parallel).
>
> Are you okay with inserting LWTUNNEL_ENCAP_IP6 before
> LWTUNNEL_ENCAP_ILA? If so, I'll resend with the explanation added.

Well, I think we should always avoid adding new entries into the
middle of enums because it will make bisecting more complex or more
difficult for example even if it *seems* that we have no users yet and
the risk is not so high.

Dave?

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
