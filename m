From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
	(v2)
Date: Sat, 23 Jan 2010 07:19:29 -0800
Message-ID: <87r5pghmri.fsf@caffeine.danplanet.com>
References: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
	<1264194592-7529-4-git-send-email-danms@us.ibm.com>
	<20100123.012537.99190542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100123.012537.99190542.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's
	message of "Sat\, 23 Jan 2010 01\:25\:37 -0800 \(PST\)")
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

DM> This is gross.  You can't do things this way.

Okay, fair enough.

DM> This misdesign is also why you find a need to get at the RTNL link
DM> ops too.  You have no infrastructure for doing what you need to do
DM> generically, so instead you are forced to directly call into
DM> drivers and export RTNL internals needlessly.

Stepping back, RTNL itself seems like the proper generic interface.
Would you agree?  At first, it seemed overkill to pack the information
into message buffers just to have the rest of RTNL unpack them, which
is why I mis-did what I did.  I think you've make it clear that that
overhead is worth the reuse.  Would that be more palatable?

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
