From: Andi Kleen <ak@suse.de>
Subject: Re: 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 14:57:48 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730145748.A11789@wotan.suse.de>
References: <20020730104815.GA22307@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Content-Disposition: inline
In-Reply-To: <20020730104815.GA22307@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2002 at 12:48:15PM +0200, bert hubert wrote:
> I'm under the strong impression that 2.4.18 lets userspace see packets with
> incorrect UDP checksums. The packet attached arrived in userspace after
> travelling all the way from Taiwan.
> 
> Is this policy?

Yes. The checksum is checked while doing the copy to user space. When the
checksum fails you still have the already done copy, the kernel does not 
try to undo it.

-Andi
