From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Wed, 27 Oct 2004 16:49:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027164912.09cc63f8.davem@davemloft.net>
References: <41797696.9070905@candelatech.com>
	<20041022214611.GA4948@electric-eye.fr.zoreil.com>
	<41798506.1030909@candelatech.com>
	<417D675F.3000909@candelatech.com>
	<417D929A.2090809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <417D929A.2090809@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Oct 2004 16:56:10 -0700
Ben Greear <greearb@candelatech.com> wrote:

> DaveM, please consider accepting this patch (it's in a previous email to netdev,
> just ask if you want it re-sent.)

Applied, but I had to apply it by hand.  It gave a large reject.
For some reason, patch barfed at the end of the vlan_dev.c parts
and refused to interpreter the parts of the diffs for the other
files.

Did you try to apply that patch to a tree before sending it off?

Anyways, I put it in by hand nevertheless.

Also, what is up with the magic "23" constant in the get realdev
name function strncpy() call?
