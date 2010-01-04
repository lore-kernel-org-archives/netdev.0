From: "Liu Dave-R63238" <r63238@freescale.com>
Subject: RE: ucc_geth: Fix the wrong the Rx/Tx FIFO size
Date: Mon, 4 Jan 2010 11:42:30 +0800
Message-ID: <D7CCA83BB0796C49BC0BB53B6AB120898BDC0E@zch01exm21.fsl.freescale.net>
References: <1259309803-5474-1-git-send-email-daveliu@freescale.com>
	<20091209230015.GA13654@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091209230015.GA13654@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> On Fri, Nov 27, 2009 at 04:16:43PM +0800, Dave Liu wrote:
> > current the Rx/Tx FIFO size settings cause problem
> > when four UEC ethernets work simultaneously.
> > 
> > eg: GETH1, UEM-J15, GETH2, UEC-J5 on 8569MDS board
> > 
> >  $ ifconfig eth0 10.193.20.166
> >  $ ifconfig eth1 10.193.20.167
> >  $ ifconfig eth2 10.193.20.168
> >  then
> >  $ ifconfig eth3 10.193.20.169
> > 
> > The fourth ethernet will cause all of interface broken,
> > you cann't ping successfully any more.
> > The patch fix this issue for MPC8569 Rev1.0 and Rev2.0
> > 
> > Signed-off-by: Dave Liu <daveliu@freescale.com>
> 
> Acked-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Thanks Dave! I see that the new values actually match the QEIWRM
> spec (except UTFS... spec recommends 2048, but it also says that
> it might differ for different memory setups, though that's a
> separate issue).
> 
> And FWIW, I did some quick netperf tests on MPC8360, and the
> patch doesn't cause any problems.

David,

How about this patch? Please consider to pick it up to your tree.

Thanks, Dave
