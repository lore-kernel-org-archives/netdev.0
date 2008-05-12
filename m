From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 01/12] lib: create common ascii hex array
Date: Tue, 13 May 2008 05:41:01 +0900
Message-ID: <20080512204101.GA17005@linux-sh.org>
References: <1210619134.24092.51.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-ide <linux-ide@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Jason Wessel <jason.wessel@windriver.com>,
	David Howells <dhowells@redhat.com>,
	"ralf@linux-mips.org" <ralf@linux-mips.org>,
	Paul Mackerras <paulus@samba.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1210619134.24092.51.camel@brick>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 12, 2008 at 12:05:34PM -0700, Harvey Harrison wrote:
> Add a common hex array in hexdump.c so everyone can use it.
> 
> Add a common hi/lo helper to avoid the shifting masking that is
> done to get the upper and lower nibbles of a byte value.
> 
> Pull the pack_hex_byte helper from kgdb as it is opencoded many
> places in the tree that will be consolidated.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Acked-by: Paul Mundt <lethal@linux-sh.org>
