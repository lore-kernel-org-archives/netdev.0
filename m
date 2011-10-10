From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 10:47:26 +0200
Message-ID: <20111010084726.GM2681@mtldesk30>
References: <1318145118.29415.371.camel@pasglop>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>, Eli Cohen <eli@mellanox.co.il>,
 Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2011 at 09:40:17AM +0100, David Laight wrote:
> 
> Actually memory barriers shouldn't really be added to
> any of these 'accessor' functions.
> (Or, at least, ones without barriers should be provided.)
> 
> The driver may want to to a series of writes, then a
> single barrier, before a final write of a command (etc).
> 
> in_le32() from io.h is specially horrid!
> 
> 	David
> 
The driver would like to control if and when we want to put a memory
barrier. We really don't want it to be done under the hood. In this
respect we prefer raw functions which are still available to all
platforms.
