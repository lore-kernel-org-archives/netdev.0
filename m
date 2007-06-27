From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Wed, 27 Jun 2007 16:53:48 +0200
Message-ID: <468279FC.3070502@trash.net>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58774 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbXF0OzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 10:55:03 -0400
In-Reply-To: <20070627121013.GB3762@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Wed, Jun 27, 2007 at 01:44:08PM +0200, Patrick McHardy wrote:
>   
>>> BTW, maybe I look at this too short, but is this del_timer()
>>> in gen_kill_estimator() enough? I cannot see nothing against
>>> a timer just running and doing mod_timer() again...
>>>       
>> Yes, but nothing bad can happen, the timer will find an empty
>> list and do nothing. It would make more sense to check for
>> an empty list before restarting the timer though.
>>
>>
>> Could you send a patch for that?
>>
>>     
>
> Probably I could, but it's your idea!
>
> I look at this just now, and maybe it's enough for asking,
> but definitely not enough for patch. I'll try to check this
> more in the evening, so I could send something tomorrow.
>
> So if it's not only about kindness, feel free to do it
> sooner and I've no doubts  - better.

I can take care of it, no problem.
