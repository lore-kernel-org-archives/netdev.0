From: Michael Weiser <michael.weiser@gmx.de>
Subject: Re: [PATCH 2/3] stmmac: change dma descriptors to __le32
Date: Fri, 29 Jul 2016 09:53:43 +0200
Message-ID: <20160729075343.GD415@weiser.dinsnail.net>
References: <20160721182329.13478-1-michael.weiser@gmx.de>
 <20160721182329.13478-3-michael.weiser@gmx.de>
 <e5229894-45fc-671e-641a-e41c7ab176d7@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandre Torgue <alexandre.torgue@st.com>,
 linux-arm-kernel@lists.infradead.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <e5229894-45fc-671e-641a-e41c7ab176d7@st.com>
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

Hi Giuseppe,

On Tue, Jul 26, 2016 at 02:13:45PM +0200, Giuseppe CAVALLARO wrote:

> > -			ep++;
> > +			ep++);
> there is a build problem here.
> Pls fix it.

Thanks for your review. I've got it fixed locally. An updated patchset
will be forthcoming as soon as I've sorted a problem with sun4i-emac
which I've been asked to look into as well.
-- 
Thanks,
Michael
