From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 17:23:14 +0200
Message-ID: <9a8748490510260823s681a4d82k5efa5734486eda85@mail.gmail.com>
References: <20051026042827.GA22836@havoc.gtf.org>
	 <200510261704.15366.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jketreno@linux.intel.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964784AbVJZPXQ@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200510261704.15366.ak@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/05, Andi Kleen <ak@suse.de> wrote:
> On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:
>
> > Change this to printing out the message once, per kernel boot.
>
> It doesn't do that. It prints it once every 2^32 calls. Also

I noted that as well. How about just using something along the lines of

static unsigned char printed_message = 0;
if (!printed_message) {
    printk(...);
    printed_message++;
}


--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
