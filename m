From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [PATCH] remove net driver ugliness that sparse complains about
Date: Sat, 29 May 2004 21:52:59 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040529205259.GJ12308@parcelfarce.linux.theplanet.co.uk>
References: <40B8D2F8.6090905@pobox.com> <Pine.LNX.4.58.0405291117511.1648@ppc970.osdl.org> <20040529204230.GG12308@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@redhat.com>,
	Arjan van de Ven <arjanv@redhat.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264373AbUE2UxC@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040529204230.GG12308@parcelfarce.linux.theplanet.co.uk>
List-Id: netdev.vger.kernel.org

On Sat, May 29, 2004 at 09:42:30PM +0100, viro@parcelfarce.linux.theplanet.co.uk wrote:
> The rest of patchset (~360Kb right now, and it will grow more) does include
> several splittings of structs, BTW.  It removes pretty much all noise on
> my alpha / amd64 / x86 builds; the rest is real issues.

BTW, could you hold on with fs/compat_ioctl.c patches?  I've got a pile
in that area and it would be really painful to untangle in case of
conflicts ;-/
