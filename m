From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] add iocb to network protocols
Date: Fri, 11 Oct 2002 16:24:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021011162448.A1309@redhat.com>
References: <20021010194025.B13432@redhat.com> <200210112015.AAA28278@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200210112015.AAA28278@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Sat, Oct 12, 2002 at 12:15:48AM +0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Oct 12, 2002 at 12:15:48AM +0400, kuznet@ms2.inr.ac.ru wrote:
> However, I do not understand this. You need to pass forth and back
> SCM_RIGHTS is some way. It is quite dubious to make this asynchronously.
> The same is surely true about credentials, they should be latched
> on entry, not at the moment of real execution.

You actually do get to execute synchronously in the user's context the 
first time the function is entered to queue the operation, so collecting 
the credentials on entry and storing them for future use will work.  I'll 
submit a cleanup that does this.

		-ben
-- 
"Do you seek knowledge in time travel?"
