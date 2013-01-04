From: Mark Zealey <netdev@markandruth.co.uk>
Subject: Re: UDP multi-core performance on a single socket and SO_REUSEPORT
Date: Fri, 04 Jan 2013 21:46:45 +0000
Message-ID: <50E74DC5.10505@markandruth.co.uk>
References: <50DD6DF1.7080304@markandruth.co.uk> <50E72493.4050406@markandruth.co.uk> <1357328238.1678.2189.camel@edumazet-glaptop> <CA+mtBx_+xR5Y5zEn6nxQ=++FEWKUw+zHzP4MamM_EEF-mMXB1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailex.mailcore.me ([94.136.40.61]:59539 "EHLO
	mailex.mailcore.me" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519Ab3ADVqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 16:46:52 -0500
In-Reply-To: <CA+mtBx_+xR5Y5zEn6nxQ=++FEWKUw+zHzP4MamM_EEF-mMXB1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/13 20:47, Tom Herbert wrote:
> I believe the hard part of making SO_REUSEPORT was on the TCP side in
> dealing with state in req structs which we have not resolved.  UDP
> SO_REUSEPORT seems to be working pretty well.

Does anyone have a SO_REUSEPORT UDP patch for a modern networking stack? 
There have been a number of changes and new functions added since the 
2010 patch that I found so I couldn't get it to work properly on 3.7.1.

Thanks,

Mark
