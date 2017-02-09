From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 1/2] net: ethernet: ucc_geth: fix MEM_PART_MURAM mode
Date: Thu, 9 Feb 2017 17:12:28 -0600
Message-ID: <CADRPPNQaU5an0ituEB62GddFK6_mR4Y7n=yOOypUfSUdMsGsLg@mail.gmail.com>
References: <cover.1486456900.git.christophe.leroy@c-s.fr>
 <d25ee7a13b60dcd005c59169feacb18fb69a06c1.1486456900.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>,
 Scott Wood <oss@buserror.net>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Qiang Zhao <qiang.zhao@nxp.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <d25ee7a13b60dcd005c59169feacb18fb69a06c1.1486456900.git.christophe.leroy@c-s.fr>
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

On Tue, Feb 7, 2017 at 3:05 AM, Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> Since commit 5093bb965a163 ("powerpc/QE: switch to the cpm_muram
> implementation"), muram area is not part of immrbar mapping anymore
> so immrbar_virt_to_phys() is not usable anymore.
>
> Fixes: 5093bb965a163 ("powerpc/QE: switch to the cpm_muram implementation)
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Acked-by: Li Yang <pku.leo@gmail.com>

Regards,
Leo
