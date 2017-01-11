From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qrtr: Mark 'buf' as little endian
Date: Tue, 10 Jan 2017 20:45:54 -0500 (EST)
Message-ID: <20170110.204554.1451403281569434916.davem@davemloft.net>
References: <20170109223158.29255-1-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bjorn.andersson@linaro.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170109223158.29255-1-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Mon,  9 Jan 2017 14:31:58 -0800

> Failure to mark this pointer as __le32 causes checkers like
> sparse to complain:
> 
> net/qrtr/qrtr.c:274:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:274:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:274:16:    got restricted __le32 [usertype] <noident>
> net/qrtr/qrtr.c:275:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:275:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:275:16:    got restricted __le32 [usertype] <noident>
> net/qrtr/qrtr.c:276:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:276:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:276:16:    got restricted __le32 [usertype] <noident>
> 
> Silence it.
> 
> Cc: Bjorn Andersson <bjorn.andersson@linaro.org>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied, thanks.
