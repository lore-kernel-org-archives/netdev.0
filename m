From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 19 Jul 2016 09:56:02 -0400
Message-ID: <578E3172.9020601@mojatatu.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net>
 <578CAA96.2090501@mojatatu.com> <578E2960.7080709@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35884 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbcGSN4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:56:07 -0400
Received: by mail-lf0-f68.google.com with SMTP id 33so1366658lfw.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 06:56:06 -0700 (PDT)
In-Reply-To: <578E2960.7080709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-19 09:21 AM, Daniel Borkmann wrote:

> True, the 32 bit chunks are more generic and as such you need to put more
> effort in user space to handle them, but at the same time gain more
> flexibility
> w/o having to have a module for each and every proto.


I dont see anything wrong with using pedit as a first step; even
if you did what Cong said he would do _i wont use it_ given the choice
against skbmod. I think we are going in circles now in this discussion.

You probably didnt mean to say module per protocol above since we only
have one action module [no different than what ebtables or openvswitch
does. It may have more justifiable extensions in the future].

> But apart from this,
> neither pedit nor tcf_skbmod_run() here handle checksum complete, so you'll
> potentially get false positives wrt csum corruption and drops as a result
> when using either of the two.
>

pedit maybe tricky. Any suggestions?
On tcf_skbmod_run, mostly ignorance: while doing only ethernet updates;
is it still needed to do the checksum complete?

cheers,
jamal
