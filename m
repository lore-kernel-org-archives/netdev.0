From: Amir Noam <amir.noam@intel.com>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] Add balance-xor-ip bonding mode
Date: Sun, 11 Jan 2004 16:50:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401111650.24305.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D2@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Per Hedeland" <per@hedeland.org>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F991D2@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 08 January 2004 06:43 pm, Per Hedeland wrote:
> Amir Noam <amir.noam@intel.com> wrote:
> >I don't like this. The reason we give different tx function
> > pointers to dev->hard_start_xmit in different bonding mode is to
> > make the tx path as fast as possible. Otherwise we might as well
> > use a single tx function that chooses its exact operation based
> > on the bonding mode.
> >
> >It might be better to have some code duplication if it results in
> >faster tx, but I'm not sure what's the optimal solution in this
> > case.
>
> Well, I don't really have an opinion since I don't have a good idea
> about the cost of a function call relative to "everything else"
> that is happening here. I don't see a way to do "limited"
> duplication without using function calls though, but I'm quite
> happy to make it two entirely separate functions for MAC vs IP.
> Please advise.

A possible way to have "limited" duplication would be to have two 
seperate xmit functions, that call an inline function for the shared 
code. This might be good enough, performance-wise, while avoiding 
some code duplication.

But, like I've said, I'm not sure wout the best solution is. I'd like 
to hear what Jay (and others) thinks about it.

-- 
Amir
