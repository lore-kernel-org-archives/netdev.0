From: Pavel Roskin <proski@gnu.org>
Subject: Re: [2.6 patch] orinoco.h: "extern inline" -> "static
	__always_inline"
Date: Tue, 15 Aug 2006 15:26:33 -0400
Message-ID: <1155669993.2063.4.camel@dv>
References: <20060815004046.GC3543@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hermes@gibson.dropbear.id.au, orinoco-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965250AbWHOT1U@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060815004046.GC3543@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 02:40 +0200, Adrian Bunk wrote:
> "extern inline" generates a warning with -Wmissing-prototypes and I'm 
> currently working on getting the kernel cleaned up for adding this to 
> the CFLAGS since it will help us to avoid a nasty class of runtime 
> errors.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Thanks for the patch!  I'm removing the last sentence in the comment as
irrelevant and fixing the comment.  The patch is being sent to netdev by
StGIT, cc: author.

-- 
Regards,
Pavel Roskin
