From: Andi Kleen <ak@suse.de>
Subject: Re: some bluetooth fixes
Date: Sat, 7 Feb 2004 12:57:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207125723.391a1fcd.ak@suse.de>
References: <20040206050042.20a2b3b0.ak@suse.de>
	<1076079512.2806.40.camel@pegasus>
	<20040207032428.56ffbebc.ak@suse.de>
	<1076152411.14418.73.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1076152411.14418.73.camel@pegasus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 12:13:31 +0100
Marcel Holtmann <marcel@holtmann.org> wrote:

> I check this. Maybe we have more of them. What do you propose as max
> size value for kmalloc? 2*PAGE_SIZE or 4*PAGE_SIZE?

What better fits the intended use case. I don't know how many objects are expected
here. Smaller is better probably.

If you want to handle more objects this way you should use seq_file instead.

-Andi
