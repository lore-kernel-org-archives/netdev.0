From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] PPC64 iSeries virtual ethernet proc files
Date: Mon, 07 Jun 2004 09:21:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C46BBC.7000001@pobox.com>
References: <20040607164312.258a9f99.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus <torvalds@osdl.org>,
        ppc64-dev <linuxppc64-dev@lists.linuxppc.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
In-Reply-To: <20040607164312.258a9f99.sfr@canb.auug.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Hi Andrew,
> 
> From: David Gibson <david@gibson.dropbear.id.au>
> 
> This patch just adds back some of the iserires_veth proc files to provide
> information to user space (particularly Kudzu) to allow the virtual
> ethernets to be discovered.  These files existed in a 2.4 version of this
> driver that was shipped by some distros.


kudzu can find this stuff with ethtool, without adding this code.

This code isn't needed in 2.6.x.

	Jeff
