From: Patrick McHardy <kaber@trash.net>
Subject: Re: spin_trylock in qdisc_restart, OOPS, IMQ problem ?
Date: Wed, 02 Mar 2005 13:34:12 +0100
Message-ID: <4225B2C4.70902@trash.net>
References: <42258DC6.9030109@cdi.cz> <4225955E.7030306@trash.net> <42259D08.1060509@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <42259D08.1060509@cdi.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Devera wrote:
> Thanks, it seems so, I'll test it. By the way, have you an idea what is
> going with that spinlocking errors I described in the last mail ?

netpoll had some locking bugs with printks issued in paths where
dev->xmit_lock is already held. IIRC patches to fix this were
posted recently.

Regards
Patrick
