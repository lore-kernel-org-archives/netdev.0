From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: 2.6.12-rc2-mm3: hostap: do not #include .c files
Date: Mon, 18 Apr 2005 19:12:38 -0700
Message-ID: <20050419021238.GG8267@jm.kir.nu>
References: <20050411012532.58593bc1.akpm@osdl.org>
	<20050419020312.GR5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com,
	hostap@shmoo.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050419020312.GR5489@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://incognito.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2005 at 04:03:12AM +0200, Adrian Bunk wrote:

> drivers/net/wireless/hostap/hostap.c:#include "hostap_crypt.c"

> Please do not #include .c files.

A tested patch would be appreciated.. ;-)

> A proper separation in a .c file and a header file is the better 
> solution.

Agreed and this is on my to-do list, but not very high on it. Some of
these would be relatively easy to fix, but the hardware specific ones
(different register offsets for PC Card/PLX/PCI) would require quite a
bit of changes to get rid of this.

-- 
Jouni Malinen                                            PGP id EFC895FA
