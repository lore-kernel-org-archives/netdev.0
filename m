From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Fri, 15 Oct 2004 21:57:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015195723.GC31195@wotan.suse.de>
References: <41701B3C.8020006@pobox.com> <200410151948.i9FJmo39006757@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Raghavendra Koushik'" <raghavendra.koushik@s2io.com>,
        "'Chris Leech'" <chris.leech@gmail.com>, ravinandan.arakali@s2io.com,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <200410151948.i9FJmo39006757@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 15, 2004 at 12:48:34PM -0700, Leonid Grossman wrote:
> OK, we will debug and try to fix this. 

iirc it was originally implemented for HIPPI because the MM 
system had some problems with allocating 64K linear buffers 
reliably. But I'm not sure anybody still uses the HIPPI 
driver so it may have been a bit bitrotted.

-Andi
