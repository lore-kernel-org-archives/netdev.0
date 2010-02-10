From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices
	(v3)
Date: Wed, 10 Feb 2010 15:01:46 -0500
Message-ID: <4B7310AA.3090708@cs.columbia.edu>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>	<1265750713-15749-3-git-send-email-danms@us.ibm.com>	<20100210172405.GB12251@us.ibm.com>
	<87pr4dgfdz.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pr4dgfdz.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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



Dan Smith wrote:
> SH> What exactly is this == 0 case?  Does it mean 'use inherited
> SH> netns'?
> 
> It means it wasn't in the checkpoint image to begin with, so yeah,
> kinda.

Maybe it's time to define CKPT_OBJREF_NULL for that ?
(to make it easy to fold, in a separate patch please)

Oren.

> 
> SH> Don't you then still need to 
> 
> SH> 	get_net(current->nsproxy->net_ns);
> SH>     nsproxy-> net_ns = current->nsproxy->net_ns;
> 
> Yes, I'll unify that path a bit.  Thanks.
> 
