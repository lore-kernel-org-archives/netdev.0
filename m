From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 1/3] sysctl: refactor integer handling proc code
Date: Wed, 05 May 2010 11:02:24 +0800
Message-ID: <4BE0DFC0.30309@redhat.com>
References: <20100430082912.5630.82405.sendpatchset@localhost.localdomain> 	<20100430082925.5630.58453.sendpatchset@localhost.localdomain> <u2s412e6f7f1004301549tb0e88a80n4c621e42c0b31015@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>, adobriyan@gmail.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908Ab0EEC6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 22:58:47 -0400
In-Reply-To: <u2s412e6f7f1004301549tb0e88a80n4c621e42c0b31015@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Fri, Apr 30, 2010 at 4:25 PM, Amerigo Wang <amwang@redhat.com> wrote:
>> +       if (*p == '-' && *size > 1) {
>> +               *neg = 1;
> 
> As neg is bool*, you should use true and false instead of 1 and 0.
> 

Yeah, I only corrected those lines that I touched, I should
correct them all.

Will fix.

Thanks.

