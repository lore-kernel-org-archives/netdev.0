From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 02/12] net: stmmac: avoid using timespec
Date: Thu, 1 Oct 2015 21:08:29 +0200
Message-ID: <20151001190829.GB1872@localhost.localdomain>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-3-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 01:26:32PM +0200, Arnd Bergmann wrote:
> We want to deprecate the use of 'struct timespec' on 32-bit
> architectures, as it is will overflow in 2038. The stmmac
> driver uses it to read the current time, and can simply
> be changed to use ktime_get_real_ts64() instead.
> 
> Because of hardware limitations, there is still an overflow
> in year 2106, which we cannot really avoid, but this documents
> the overflow.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Richard Cochran <richardcochran@gmail.com>
