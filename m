From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Tue, 06 Mar 2012 16:34:54 +0200
Message-ID: <4F56208E.2090801@gmail.com>
References: <20120306142219.31783.30201.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([85.255.61.7]:48683 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030721Ab2CFOmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:42:24 -0500
In-Reply-To: <20120306142219.31783.30201.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2012 04:22 PM, Paulius Zaleckas wrote:
> Now we have:
> eth0: link down
> br0: port 1(eth0) entering forwarding state
>
> State should be logged *after* it was changed, not before.

The funny thing is that it was introduced:
2010-05-16 	stephen hemminger
bridge: change console message interface
28a16c97963d3bc36a2c192859f6d8025ef2967a

and no one noticed since then :D
