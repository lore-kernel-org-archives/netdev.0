From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [e2e] performance of BIC-TCP, High-Speed-TCP, H-TCP etc
Date: Sat, 23 Sep 2006 08:04:48 +1200
Message-ID: <5640c7e00609221304h78689765kd63d2bc2e985d42e@mail.gmail.com>
References: <4513F1A1.3000506@nuim.ie>
	 <5640c7e00609221042w5122c37cm7db3013e21e3b5dc@mail.gmail.com>
	 <45143B9F.9080000@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: end2end-interest@postel.org, netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.131]:26790 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S964867AbWIVUEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 16:04:50 -0400
Received: by nf-out-f131.google.com with SMTP id k65so51029nfa
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 13:04:49 -0700 (PDT)
To: "Douglas Leith" <doug.leith@nuim.ie>
In-Reply-To: <45143B9F.9080000@nuim.ie>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I wasn't aware of the planned move to cubic in Linux.  Can I ask the
> rationale for this ?  Cubic is, of course, closely related to HTCP
> (borrowing the HTCP idea of using elapsed time since last backoff as the
> quantity used to adjust the cwnd increase rate) which *is* tested in the
> reported study.  I'd be more than happy to run tests on cubic and I
> reckon we should do this sooner rather than later now that you have
> flagged up plans to rollout cubic.
>
As I understand it, it is because Cubic is better than bic for
differing rtts and bic is the current default. Stephen might like to
add to it.

More tests are always good!

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
