From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netdevice: provide common routine for macvlan and vlan
 operstate management
Date: Thu, 12 Nov 2009 19:21:08 +0100
Message-ID: <4AFC5214.9030108@trash.net>
References: <4AFAD86A.9070506@trash.net> <20091112180137.10186.9386.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arnd@arnd.de, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.rog
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753861AbZKLSVI@vger.kernel.org>
In-Reply-To: <20091112180137.10186.9386.stgit@mimic.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick Mullaney wrote:
> This patch is intended to address your comment on moving the operstate
> transition function. I decided to move it to netdevice.h, perhaps that
> is a bad idea? It didn't seem to logically fall into dev.c or link_watch.c.
> I am not against moving them to either one though. Your other comments
> are addressed and I will send out a second series once this gets
> reviewed and agreed on.

Thanks. I don't mind much where exactly it is located, but I'd prefer
to not have it inlined. It doesn't seem terribly wrong to move it to
dev.c, there are even some helpers for stacked devices already, like
address list synchronization.

Besides that the patch looks fine to me.
