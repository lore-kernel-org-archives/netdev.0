From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Tue, 6 Mar 2012 09:09:05 -0800
Message-ID: <20120306090905.0bc1a527@nehalam.linuxnetplumber.net>
References: <20120306142219.31783.30201.stgit@localhost.localdomain>
 <4F56208E.2090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42774 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759Ab2CFRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 12:09:08 -0500
In-Reply-To: <4F56208E.2090801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Mar 2012 16:34:54 +0200
Paulius Zaleckas <paulius.zaleckas@gmail.com> wrote:

> On 03/06/2012 04:22 PM, Paulius Zaleckas wrote:
> > Now we have:
> > eth0: link down
> > br0: port 1(eth0) entering forwarding state
> >
> > State should be logged *after* it was changed, not before.
> 
> The funny thing is that it was introduced:
> 2010-05-16 	stephen hemminger
> bridge: change console message interface
> 28a16c97963d3bc36a2c192859f6d8025ef2967a
> 
> and no one noticed since then :D

The message could be corrected to have correct verb tense. s/entering/entered/

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
