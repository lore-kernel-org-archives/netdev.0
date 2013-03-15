From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: DaVinci platform unable to boot via NFS
Date: Fri, 15 Mar 2013 19:11:19 +0530
Message-ID: <CA+V-a8sNLBi1zB942ZbK26POrzcq7oOpNW9yPG5dG_gX7ZZ1oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 dlos <davinci-linux-open-source@linux.davincidsp.com>,
 Sekhar Nori <nsekhar@ti.com>, LAK <linux-arm-kernel@lists.infradead.org>
To: mugunthanvnm@ti.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Mugunthan,

With 3.9 release I am not able to boot any davinci board via nfs, finally
digging Into I found that there were recent changes for Ethernet davinci.
Finally I reverting this to some safe commit I was able to boot via nfs.
I reverted back as following:-
git checkout  f9a8f83b04e0c362a2fc660dbad980d24af209fc  drivers/net/ethernet/ti/

Can you please take a look at and fix it.

Cheers,
--Prabhakar Lad
http://in.linkedin.com/pub/prabhakar-lad/19/92b/955
