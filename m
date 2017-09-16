From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2] tipc: Use bsearch library function
Date: Sat, 16 Sep 2017 02:58:28 -0700
Message-ID: <1505555908.16316.5.camel@perches.com>
References: <20170911.143025.555018840006192902.davem@davemloft.net>
         <20170916075036.28676-1-thomas@m3y3r.de>
         <16128f5e-66ff-b6ec-c0e1-74ea08c212b0@windriver.com>
         <1505553970.16316.1.camel@perches.com>
         <64ee51ce-eb7e-ac1c-56a9-9481f6f80b35@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Ying Xue <ying.xue@windriver.com>, Thomas Meyer <thomas@m3y3r.de>,
        jon.maloy@ericsson.com, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <64ee51ce-eb7e-ac1c-56a9-9481f6f80b35@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-09-16 at 17:36 +0800, Ying Xue wrote:
> On 09/16/2017 05:26 PM, Joe Perches wrote:
> > On Sat, 2017-09-16 at 17:02 +0800, Ying Xue wrote:
> > > On 09/16/2017 03:50 PM, Thomas Meyer wrote:
> > > > Use common library function rather than explicitly coding
> > > > some variant of it yourself.
> > > > 
> > > > Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> > > 
> > > Acked-by: Ying Xue <ying.xue@windriver.com>
> > 
> > Are you sure you want to do this?
> > 
> > Note the comment above nameseq_find_subseq
> > 
> >  * Very time-critical, so binary searches through sub-sequence array.
> > 
> > What impact does this change have on performance?
> 
> Sorry, I couldn't see any essential difference between this new
> implementation and the original one except that the former tries to use
> the library function - bsearch() to replace the original binary search
> algorithm implemented in TIPC itself. Therefore, I don't think the
> change will have a big impact on performance.
> 
> If I miss something, please let me know.

Comparison via a function pointer in bsearch is slower
than direct code without the function call overhead.
