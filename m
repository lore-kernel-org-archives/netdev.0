From: hallyn@CS.WM.EDU (Serge E. Hallyn)
Subject: Re: [PATCH] BSD Jail LSM (2/3)
Date: Mon, 13 Sep 2004 11:08:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913150851.GA15000@escher.cs.wm.edu>
References: <1094847705.2188.94.camel@serge.austin.ibm.com> <1094847787.2188.101.camel@serge.austin.ibm.com> <1094844708.18107.5.camel@localhost.localdomain> <20040912233342.GA12097@escher.cs.wm.edu> <1095072996.14355.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@osdl.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1095072996.14355.12.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Alan Cox (alan@lxorguk.ukuu.org.uk):
> On Llu, 2004-09-13 at 00:33, Serge E. Hallyn wrote:
> > Right now one must choose between either an ipv4 or ipv6 interface.
> > Is typical ipv6 usage such that it would be preferable to be able to
> > specify one of each?  
> 
> Its normal to have both yes.
> 
> A more interesting question is whether all of the "which socket for
> which use" stuff could be addressed by netfilter chains run at
> bind/connect time ?

You mean to add two new netfilter hooks?  Would these then replace the
LSM hooks?

-serge
