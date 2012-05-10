From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 Resend 09/12] net/stmmac: Remove conditional
 compilation of clk code
Date: Wed, 09 May 2012 21:22:43 -0400 (EDT)
Message-ID: <20120509.212243.1590217502497756920.davem@davemloft.net>
References: <cover.1336448639.git.viresh.kumar@st.com>
 <8e66b900fe5ee10c8db93d2f12c912e3dfb0708f.1336448639.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, mturquette@linaro.org, sshtylyov@mvista.com,
 netdev@vger.kernel.org, spear-devel@list.st.com, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, viresh.linux@gmail.com, peppe.cavallaro@st.com,
 linux@arm.linux.org.uk, akpm@linux-foundation.org, jgarzik@redhat.com,
 linux-arm-kernel@lists.infradead.org, LW@KARO-electronics.de
To: viresh.kumar@st.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <8e66b900fe5ee10c8db93d2f12c912e3dfb0708f.1336448639.git.viresh.kumar@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Viresh Kumar <viresh.kumar@st.com>
Date: Tue, 8 May 2012 09:22:36 +0530

> With addition of dummy clk_*() calls for non CONFIG_HAVE_CLK cases in clk.h,
> there is no need to have clk code enclosed in #ifdef CONFIG_HAVE_CLK, #endif
> macros.
> 
> This also fixes error paths of probe(), as a goto is required in this patch.
> 
> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>

Acked-by: David S. Miller <davem@davemloft.net>
