From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: shutdown(3) and bluetooth.
Date: Wed, 13 Nov 2013 09:02:40 -0500
Message-ID: <20131113140239.GA2154@tuxdriver.com>
References: <20131112211125.GA2912@redhat.com>
 <20131112.161350.946584501122269943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davej@redhat.com, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35405 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759112Ab3KMOPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:15:19 -0500
Content-Disposition: inline
In-Reply-To: <20131112.161350.946584501122269943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 04:13:50PM -0500, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Tue, 12 Nov 2013 16:11:25 -0500
> 
> > Is shutdown() allowed to block indefinitely ? The man page doesn't say either way,
> > and I've noticed that my fuzz tester occasionally hangs for days spinning in bt_sock_wait_state()
> > 
> > Is there something I should be doing to guarantee that this operation
> > will either time out, or return instantly ?
> > 
> > In this specific case, I doubt anything is on the "sender" end of the socket, so
> > it's going to be waiting forever for a state change that won't arrive.
> 
> Adding bluetooth and wireless lists.  Dave, please consult MAINTAINERS when
> asking questions like this, thanks!

I don't have an authoritative answer.  I do, however, seem to recall
that trying to shutdown a SunOS box with a hung NFS mount would seem
to hang forever.  I don't think that is a great metric for how we
should behave, of course...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
