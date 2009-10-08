From: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Thu, 08 Oct 2009 18:10:08 +0000
Message-ID: <1255025408.8033.25.camel@Maple>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-3-git-send-email-danms@us.ibm.com>
	<1255013233.8033.14.camel@Maple>
	<87ab01gag7.fsf@caffeine.danplanet.com>
	<1255023087.8033.17.camel@Maple>
	<8763apg57w.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8763apg57w.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-10-08 at 10:34 -0700, Dan Smith wrote:
> JD> Yep.  It sort of messes up your separation between layers, though.
> 
> In what way?  It's just this:

I just meant that you're peeking into the checkpointed sk data before
you create the new sk.  In so much of your code, you manage to restore
structs as a whole, without peeking first.

> Which seems like a why-didn't-I-do-that-in-the-first-place sort of
> thing...   Am I missing something?

Not anything that I see.  

  --  John
