From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and
 clip_start_xmit()
Date: Mon, 15 Sep 2003 15:24:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915152408.2b9bae8a.davem@redhat.com>
References: <20030915225901.A22239@electric-eye.fr.zoreil.com>
	<200309152159.h8FLx1Sa005910@ginger.cmf.nrl.navy.mil>
	<20030915150217.06b03168.davem@redhat.com>
	<20030915223048.GD92642@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030915223048.GD92642@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 15:30:48 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> David S. Miller wrote:
> > Are you really totally sure that no interrupt path can release
> > a VCC?
> 
> That should be the case at least for any VCC on a real interface[*].
> Some ATM cards have ->close() methods that can take a while so connection
> teardown has to happen with some sort of sleepable context.  So if there
> are cases where an interrupt causes the VCC to die they would need to be
> fixed anyways.

Ok, I'm convinced. :)

I'll apply Chas's patch then, thanks.
