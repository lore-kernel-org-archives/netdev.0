From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 0/3] qlge: Size RX buffers based on MTU.
Date: Fri, 16 Oct 2009 19:22:10 -0700
Message-ID: <20091017022210.GA14919@linux-ox1b.qlogic.org>
References: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com> <20091016.175142.52482970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:14295 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbZJQC2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 22:28:05 -0400
Content-Disposition: inline
In-Reply-To: <20091016.175142.52482970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 05:51:42PM -0700, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Fri, 16 Oct 2009 13:15:33 -0700
> 
> > These patches are interdependent.
> 
> No, Ron, they are absolutely not.
> 
> Apply the first patch, and that breaks the build because
> you've removed LARGE_BUFFER_SIZE but it's still referenced
> in qlge_main.c, and there are tons of other breakages too.
> 
> Don't send me garbage like this and then claim it's a set
> of independent patches.  A trivial build test would have
> shown otherwise, but you obviously didn't do that.
> 
> This is completely rediculious:

Hi Dave,

Sorry for the confusion.  I said they were 'interdependent' patches, meaning
"depending on each other".  I was trying to break this up to
make it easier to review.  Shall I send it as a single patch?

Thanks,
Ron


