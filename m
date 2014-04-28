From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 2/2] FDDI: DEC FDDIcontroller 700
 TURBOchannel card support
Date: Mon, 28 Apr 2014 12:52:44 -0400 (EDT)
Message-ID: <20140428.125244.18665502106315120.davem@davemloft.net>
References: <alpine.LFD.2.11.1404250159220.11598@eddie.linux-mips.org>
        <20140427.191346.2115795102984045600.davem@davemloft.net>
        <alpine.LFD.2.11.1404280048540.11598@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
        linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: macro@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <alpine.LFD.2.11.1404280048540.11598@eddie.linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Mon, 28 Apr 2014 12:37:08 +0100 (BST)

>  That however I would like to keep -- I find it particularly valuable and 
> a great advantage of this piece of hardware to be able to tap into all the 
> SMT traffic crossing this adapter, both incoming and outgoing, for 
> educational and diagnostic purposes.  Without this capability a second 
> FDDI station is required to be able to see both traffic streams, and also 
> it has to be exactly the next downstream neighbour or some traffic will 
> undoubtedly be stripped from the ring by intermediate stations.
> 
>  Therefore I would like to retain this capability.  If you're unhappy with 
> tapping in directly, then I think sending them back down the usual receive 
> path would do, although at some performance hit.  So I'd prefer to avoid 
> it if possible -- can you propose an alternative by any chance?
> 
>  Thanks for your review, please let me know how to proceed with the issues 
> that remain open.  I'll send updated code once we've settled, I think 
> there's little point in publishing an update before then.

We're not exporting all of these internals for the unique desires of
one single driver.
