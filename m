From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patch] urgent e1000 fix
Date: Thu, 23 Jun 2005 19:10:42 -0400
Message-ID: <42BB4172.5000904@pobox.com>
References: <42BA7FB5.5020804@pobox.com> <Pine.LNX.4.62.0506231402340.18154@qynat.qvtvafvgr.pbz> <42BB2749.1020209@pobox.com> <Pine.LNX.4.58.0506231506510.11175@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262286AbVFWXLd@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0506231506510.11175@ppc970.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Thu, 23 Jun 2005, Jeff Garzik wrote:
> 
>>It's probably the whitespace thing that Linus's git-apply gadget was 
>>complaining about.
>>
>>I'm terribly surprising, though, since my patch(1) applied the diff just 
>>fine.
> 
> 
> I could easily make git-apply accept empty lines as if they had a single 
> space on it. What I find surprising is that "patch" allows that kind of 
> whitespace corruption by default, and silently. Usually you have to give 
> it the "-l" flag to make it ignore whitespace differences..


patch(1) is a huge collection of heuristics like this, even without 
'-l', so I'm not surprised that it worked.

Does git-apply support patches with "fuzz", out of curiosity?

	Jeff
