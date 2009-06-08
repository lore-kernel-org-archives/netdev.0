From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Fix napi_enable BUG_ON when
 recovering from EEH error
Date: Mon, 08 Jun 2009 00:42:38 -0700 (PDT)
Message-ID: <20090608.004238.232927107.davem@davemloft.net>
References: <200906051704.25753.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: adetsch@br.ibm.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200906051704.25753.adetsch@br.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Andre Detsch <adetsch@br.ibm.com>
Date: Fri, 5 Jun 2009 17:04:25 -0300

> BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state)) was being hit
> during e100 EEH recovery. The problem source was a napi_enable
> call being made during e100_io_error_detected. Napi should remain
> disabled after e100_down, and only be reenabled when the interface
> is recovered.
> 
> This patch also updates e100_io_error_detected in order to make
> it similar to the current versions of the error_detected callback
> in drivers such as e1000e and ixgbe.
> 
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Applied, thank you.

------------------------------------------------------------------------------
OpenSolaris 2009.06 is a cutting edge operating system for enterprises 
looking to deploy the next generation of Solaris that includes the latest 
innovations from Sun and the OpenSource community. Download a copy and 
enjoy capabilities such as Networking, Storage and Virtualization. 
Go to: http://p.sf.net/sfu/opensolaris-get
