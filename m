From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Wed, 27 Jun 2007 13:44:08 +0200
Message-ID: <46824D88.1090300@trash.net>
References: <20070627114521.GA3762@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54840 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbXF0LpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 07:45:21 -0400
In-Reply-To: <20070627114521.GA3762@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 25-06-2007 11:28, Patrick McHardy wrote:
> ...
>   
>> It is. This patch I had originally planned for 2.6.23 switches HTB
>> to the generic estimator, which shouldn't suffer from this.
>>     
>
> BTW, maybe I look at this too short, but is this del_timer()
> in gen_kill_estimator() enough? I cannot see nothing against
> a timer just running and doing mod_timer() again...

Yes, but nothing bad can happen, the timer will find an empty
list and do nothing. It would make more sense to check for
an empty list before restarting the timer though.


Could you send a patch for that?

