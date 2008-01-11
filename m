From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Fri, 11 Jan 2008 09:48:22 -0800
Message-ID: <20080111174822.GB17240@gate.ebshome.net>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	<1199528388.7291.55.camel@pasglop> <200801051338.17957.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200801051338.17957.sr@denx.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 05, 2008 at 01:38:17PM +0100, Stefan Roese wrote:
> On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> > On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > > Performance tests done by AMCC have shown that 256 buffer increase the
> > > performance of the Linux EMAC driver. So let's update the default
> > > values to match this setup.
> > >
> > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > ---
> >
> > Do we have the numbers ? Did they also measure latency ?
> 
> I hoped this question would not come. ;) No, unfortunately I don't have any 
> numbers. Just the recommendation from AMCC to always use 256 buffers.

This cannot be true for all chips. Default numbers I selected weren't 
random. In particular, 256 for Tx doesn't make a lot of sense for 405. 
You just gonna waste memory.

I'd be quite reluctant to follow such advices from AMCC without actual 
details. 

-- 
Eugene
