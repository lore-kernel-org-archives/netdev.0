From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap: allow flashing firmware
Date: Wed, 4 Jan 2006 21:18:57 -0800
Message-ID: <20060105051857.GO8939@jm.kir.nu>
References: <1135984946.17805.21.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, hostap <hostap@shmoo.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1135984946.17805.21.camel@dv>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 30, 2005 at 06:22:26PM -0500, Pavel Roskin wrote:

> Host AP driver has code to support writing firmware to non-volatile
> memory, a.k.a. flash.  This code has been extensively tested when Host
> AP was a standalone driver.
> 
> Add a configuration option to the kernel to allow enabling this
> functionality.  Improve the description of the RAM download option. 
> Mention cards that require it.  Remove obsolete scary comment.

I'm not completely against this change, but that scary comment is there
on purpose and it is not fully obsolete. It is still possible to get
HFA3841 cards into state which require hardware modifications to recover
from (i.e., they are as good as dead for most users). Taken into this
account, I would prefer that the help text for HOSTAP_FIRMWARE_NVRAM
would include a warning about the potential issues of using incorrect
firmware images. In most cases, RAM (volatile) download can be used to
upgrade the firmware without having to modify the flash contents. This
is also what the current Windows drivers are doing.

-- 
Jouni Malinen                                            PGP id EFC895FA
