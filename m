From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH retry] bluetooth : add conn add/del
	workqueues to avoid	connection fail
Date: Wed, 30 Jan 2008 11:21:02 +0100
Message-ID: <1201688462.6218.47.camel@violet>
References: <20080130022354.GA3132@darkstar.te-china.tietoenator.com>
	<20080129.211446.254604070.davem@davemloft.net>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bluez-devel@lists.sf.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080129.211446.254604070.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Dave,

> > The bluetooth hci_conn sysfs add/del executed in the default workqueue.
> > If the del_conn is executed after the new add_conn with same target,
> > add_conn will failed with warning of "same kobject name".
> > 
> > Here add btaddconn & btdelconn workqueues,
> > flush the btdelconn workqueue in the add_conn function to avoid the issue.
> > 
> > Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> 
> This looks good, applied, thanks Dave.
> 
> I've queued this up for 2.6.25 merging, if you want me to
> schedule it for -stable, just let me know.

don't include it. I first have to stress test it on one of my machines.
Besides that I have to do some coding style cleanups.

Regards

Marcel



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
