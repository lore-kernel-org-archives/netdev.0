From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [PATCH] remove net driver ugliness that sparse complains about
Date: Sat, 29 May 2004 21:44:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529204457.GI12308@parcelfarce.linux.theplanet.co.uk>
References: <40B8D2F8.6090905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
        Arjan van de Ven <arjanv@redhat.com>,
        Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40B8D2F8.6090905@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 29, 2004 at 02:14:16PM -0400, Jeff Garzik wrote:
 
> I'm a bit curious why sparse complained about taking the _address_ of 
> pointer, but nonetheless it's an ugliness that should be contained 
> before it spreads :)  Attached is a proposed cleanup patch for comment. 
>  The ugliness is confined to include/linux/mii.h, and I avoid use the 
> ifru_data field completely.

sparse hadn't ;-)  I had, when I saw it in grep output.
