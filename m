From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Tue, 3 Feb 2009 05:58:33 +0100
Message-ID: <20090203045833.GA11639@uranus.ravnborg.org>
References: <20090202.120507.152093960.davem@davemloft.net> <498761E7.3080006@walrond.org> <20090202.132450.21504465.davem@davemloft.net> <20090202.132723.38842373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@walrond.org, jengelh@medozas.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753690AbZBCE5E@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090202.132723.38842373.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 02, 2009 at 01:27:23PM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 02 Feb 2009 13:24:50 -0800 (PST)
> 
> > I guess I'll put in the following hack for now:
> > 
> > diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
> > index aeab2cb..82c4362 100644
> 
> Need to also update linux/Kbuild, here is an updated patch:

All headers are unifdeffed - so the Kbuild patch
is not needed.

	Sam
