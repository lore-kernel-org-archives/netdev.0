From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/1] ixgbe: write flush vfta registers
Date: Wed, 7 Dec 2016 20:24:50 +0100
Message-ID: <7c5c0227-04a1-fed9-9b56-4e2755f9a005@gmx.de>
References: <1479300041-3436-1-git-send-email-zyjzyj2000@gmail.com>
	<trinity-ec3a2e6f-7310-41aa-8743-61bc62ccf663-1479305144399@3capp-gmx-bs59>
	<CAD=hENfbWUobVvUOKhjRi+7fNCj=87R3GFeGjXg+zd_zez_SpQ@mail.gmail.com>
	<CAD=hENcE58xM4hBm-8N-eNREhBbP4gC-Vm89krQ6aj_8bDZmJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAD=hENcE58xM4hBm-8N-eNREhBbP4gC-Vm89krQ6aj_8bDZmJg@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Zhu,

On 07.12.2016 04:05, zhuyj wrote:
> After several week tests, your advice still make this bug appear. But
> my patch make this bug disappear.
> 
> Zhu Yanjun
> 

In your commit message you wrote
"Sometimes vfta registers can not be written successfully in dcb mode." 
Do you mean that the writes to the registers dont seem to have any effect at all? Or is the
effect only delayed? What exactly is your test case?

(BTW: please dont top-post).

Regards,
Lino

------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today.http://sdm.link/xeonphi
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
