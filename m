From: =?ISO-8859-1?Q?Jochen_Vo=DF?= <voss@seehuhn.de>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Wed, 14 Mar 2007 09:45:09 +0000
Message-ID: <A641066C-5E6B-459E-8244-87ECAB378583@seehuhn.de>
References: <20070314005508.DDC121801C5@magilla.sf.frob.com> <Pine.LNX.4.64.0703131814160.9690@woody.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland McGrath <roland@redhat.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seehuhn.de ([80.68.93.199]:4453 "EHLO seehuhn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161038AbXCNKJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 06:09:36 -0400
In-Reply-To: <Pine.LNX.4.64.0703131814160.9690@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 14 Mar 2007, at 01:15, Linus Torvalds wrote:
> On Tue, 13 Mar 2007, Roland McGrath wrote:
>> Ok, fine.  But PATH_MAX is a real constant that has some meaning  
>> in the
>> kernel.  It's perfectly correct to use PATH_MAX as a constant on a  
>> system
>> like Linux that defines it and means what it says.  Conversely,  
>> OPEN_MAX
>> has no useful relationship with anything the kernel is doing at all.
>
> Sure. I'm just saying that some people may use OPEN_MAX the way I know
> people use PATH_MAX - whether it's what you're supposed to or not.

To contribute a data point here: searching for the regular expression

     \[\ *OPEN_MAX\ *\]

on google code search [1] gives 25 hits for me.  Replacing OPEN_MAX  
with PATH_MAX results in "about 19,700" hits.

[1] http://www.google.com/codesearch?hl=en&q=+%5C%5B%5C+*OPEN_MAX%5C+* 
%5C%5D&start=20&sa=N

I hope this helps,
Jochen
--
http://seehuhn.de/


