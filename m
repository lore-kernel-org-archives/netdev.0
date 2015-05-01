From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Fri, 01 May 2015 08:08:18 -0400
Message-ID: <55436CB2.9070506@mojatatu.com>
References: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35517 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbbEAMIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:08:20 -0400
Received: by iejt8 with SMTP id t8so87692868iej.2
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 05:08:20 -0700 (PDT)
In-Reply-To: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/15 23:14, Alexei Starovoitov wrote:
> TC classifiers/actions were converted to RCU by John in the series:
> http://thread.gmane.org/gmane.linux.network/329739/focus=329739
> and many follow on patches.
> This is the last patch from that series that finally drops
> ingress spin_lock.
>

As the culprit who added this lock I would like to offer a kudos
to John for the hard work. Alexei thanks for the hard work in
pursuing this further.
And to the rest of the community who has been beating up on me
all these years, you can stop now ;->

I think this at least deserves a:
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
