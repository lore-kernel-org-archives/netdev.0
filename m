From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c
Date: Wed, 8 Oct 2003 09:01:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008090132.2b58c067.davem@redhat.com>
References: <20031007175953.GA1802@averell>
	<20031008084205.5c81faac.davem@redhat.com>
	<20031008155548.GB16937@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, ncorbic@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008155548.GB16937@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 17:55:48 +0200
Andi Kleen <ak@suse.de> wrote:

> I agree it would have been better to write:
> "ioremap and ioremap_nocache return pointers and that should 
> be stored in a pointer variable. However when you really want 
> to store them in a integer variable for unknown reasons always
> use unsigned long, not u32 or int"
> 
> However that was just too long, so I didn't write it.

Don't replace one error with a new warning, just add the cast
to the ioremap() call or something like that.
