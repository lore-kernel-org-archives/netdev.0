From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ipw2100 wireless driver
Date: Wed, 11 Aug 2004 11:44:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811114437.A27439@infradead.org>
References: <20040714114135.GA25175@elf.ucw.cz> <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com> <20040714115523.GC2269@elf.ucw.cz> <20040809201556.GB9677@louise.pinerecords.com> <Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com> <20040810075558.A14154@infradead.org> <20040810101640.GF9034@atrey.karlin.mff.cuni.cz> <4119F203.1070009@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@suse.cz>, Christoph Hellwig <hch@infradead.org>,
        Jeff Chua <jeffchua@silk.corp.fedex.com>,
        Tomas Szepe <szepe@pinerecords.com>, netdev@oss.sgi.com,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <4119F203.1070009@linux.intel.com>; from jketreno@linux.intel.com on Wed, Aug 11, 2004 at 05:16:35AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 11, 2004 at 05:16:35AM -0500, James Ketrenos wrote:
> We're currently working to clean up ipw2100 and ieee80211 code for submission to 
> netdev for discussion and hopefully inclusion in the future.  The ieee80211 code 
> is still being heavily developed, but its usable.  If anyone wants to help out, 
> or if folks feel its ready as-is to get pulled into wireless-2.6, let me know.

Maybe we should switch to your ieee802.11 for a generic wireless stack then
instead of the original hostap code.  At least it seems more actively
maintained right now and supports two drivers already.

Btw, I've looked at the ipw2100 and have to concerns regarding the firmware,

 a) yo'ure not using the proper firmware loader but some horrible
    handcrafted code using sys_open/sys_read & co that's not namespace
    safe at all
 b) the firmware has an extremly complicated and hard to comply with license,
    I'm not sure we want a driver that can't work without a so strangely
    licensed blob in the kernel. Can you talk to intel lawyers and put it on
    simple redristribution and binary modification for allowed for all purposes
    license please?
    

 
> Thanks,
> James
> 
> 
> 
---end quoted text---
