From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] pcmcia: hostap_cs.c - 0xc00f,0x0000 conflicts with pcnet_cs
Date: Sat, 1 Jul 2006 01:23:01 -0400
Message-ID: <20060701052256.GA8749@tuxdriver.com>
References: <200607010001.k610165k008843@hera.kernel.org> <44A5C2FC.9000908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>, linux@dominikbrodowski.net,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964775AbWGAFXp@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44A5C2FC.9000908@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 08:34:04PM -0400, Jeff Garzik wrote:
> Linux Kernel Mailing List wrote:
> >commit fd99ddd0701385344eadaf2daa6abbc5fb086750
> >tree 013d75048f086edfa7a89ac3f3301dde13017817
> >parent 0db6095d4ff8918350797dfe299d572980e82fa0
> >author Komuro <komurojun-mbn@nifty.com> Mon, 17 Apr 2006 21:41:21 +0900
> >committer Dominik Brodowski <linux@dominikbrodowski.net> Fri, 30 Jun 2006 
> >22:09:12 +0200
> >
> >[PATCH] pcmcia: hostap_cs.c - 0xc00f,0x0000 conflicts with pcnet_cs
> >
> >Comment out the ID 0xc00f,0x0000 in hostap_cs.c, as it conflicts with the
> >pcnet_cs driver.
> >
> >Signed-off-by: komurojun-mbn@nifty.com
> >Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> >
> > drivers/net/wireless/hostap/hostap_cs.c |    2 +-
> > 1 files changed, 1 insertion(+), 1 deletion(-)
> 
> drivers/net/wireless stuff should go through netdev and John Linville.
> 
> I'm going to go out on a limb, and guess that Linville never saw this patch?

Actually, I did get a copy.  I also saw a comment from Pavel
Roskin, but it wasn't sure if it was an ACK, a NACK, or something
in between...?

John
-- 
John W. Linville
linville@tuxdriver.com
