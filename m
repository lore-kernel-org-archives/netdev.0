From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion
	timout on Pseries	HW
Date: Thu, 17 May 2007 08:31:36 +1000
Message-ID: <1179354696.32247.231.camel@localhost.localdomain>
References: <OFF304A49A.2C1F7634-ON872572DD.0079C647-862572DD.0079EE19@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>, Jeff Garzik <jeff@garzik.org>
To: Wen Xiong <wenxiong@us.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <OFF304A49A.2C1F7634-ON872572DD.0079C647-862572DD.0079EE19@us.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-16 at 17:11 -0500, Wen Xiong wrote:
>  little history, on PCI-X adapters we did not time dma reads being
> returned to the adapter. On PCIe unfortunately the spec says that
> adapters need to time the dma reads the spec is not specific on the
> range but the timers can range from worst case 50 usecs to 10 ms with
> some adapters supporting upto 50ms. The PCIe spec has approved an ECR
> to the PCIe 1.0a spec that will support the ability to disable the
> timer.  To work aroung the adapter doesn't support ECR.  We need the
> driver to disable the timer. 

You do get more than 10ms delay for DMA replies on pSeries ? Ouch...

Ben.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
