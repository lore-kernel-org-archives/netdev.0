From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and
 clip_start_xmit()
Date: Mon, 15 Sep 2003 15:02:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915150217.06b03168.davem@redhat.com>
References: <20030915225901.A22239@electric-eye.fr.zoreil.com>
	<200309152159.h8FLx1Sa005910@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
In-Reply-To: <200309152159.h8FLx1Sa005910@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 17:59:02 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> this is triggered by vcc_destroy_sock(), which is part of vcc_release()
> which is always going to be in user context.  its a bit subtle but
> there is no path to unlink_clip_vcc() that isnt in user context.

Are you really totally sure that no interrupt path can release
a VCC?  That's not how I understood this stuff to work last time
I looked at it.
