From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: switching network namespace midway
Date: Thu, 25 Oct 2012 10:38:11 -0400
Message-ID: <20121025143811.GH15034@kvack.org>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com> <878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org> <87ip9zqqlv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49141 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758956Ab2JYOiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 10:38:13 -0400
Content-Disposition: inline
In-Reply-To: <87ip9zqqlv.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On Wed, Oct 24, 2012 at 06:37:16PM -0700, Eric W. Biederman wrote:
> Yes.  Although L2TP is not an example of code I would copy.  Any other
> tunnel would be better.  I haven't looked closely at L2TP but it keeps
> popping up as a poster child for small little network namespace bugs
> that I don't want to think about.

Agreed.

> Last I looked to use L2TP it required a magic userspace that I couldn't
> find and I haven't cared enough to write.  Ben would you be interested
> in helping flush out the network namespace bugs out of L2TP?

Sure, that I can do.  To be entirely honest, I have not yet tried using 
network namespaces with the in kernel L2TP stack, but rather with the 
Babylon code.  I have, however, put together changes to make the Babylon 
userland code work with the in kernel L2TP over the past couple of months.  
Since the network namespace support is already present in the userland 
code, it shouldn't be too hard to adapt.

>From a quick read of the L2TP over UDP code paths, it looks like things 
should work, as the ingress and egress lookups use the transport socket's 
namespace.  All the reference counting looks a bit heavy handed, though.  
I also wrote a couple of test programs for setting up L2TP sockets and 
devices which may be of use -- see http://www.kvack.org/~bcrl/pppol2tp/ .

		-ben
-- 
"Thought is the essence of where you are now."
