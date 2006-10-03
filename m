From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 4/6] 2.6.18: sb1250-mac: The actual driver update
Date: Tue, 3 Oct 2006 16:42:53 -0700
Message-ID: <20061003164253.62f9d5a3.akpm@osdl.org>
References: <Pine.LNX.4.64N.0610031549270.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5776 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751035AbWJCXq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 19:46:26 -0400
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0610031549270.4642@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006 16:18:44 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

> +	sbmac_state_t		sbm_state;	/* current state */

argh.

The reader looks at this and doesn't know if it's an integer, a void*, a
struct usb_ac_header_descriptor** or what.

	enum sbmac_state	smb_state;

is nicer.  It has information.
