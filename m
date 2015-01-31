From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: xgene: fix: Out of order descriptor
 bytes read
Date: Fri, 30 Jan 2015 18:24:53 -0800 (PST)
Message-ID: <20150130.182453.1030337100939592336.davem@davemloft.net>
References: <1422571103-17497-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com, eric.dumazet@gmail.com, kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422571103-17497-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 29 Jan 2015 14:38:23 -0800

> This patch fixes the following kernel crash,
 ...
> Software writes poison data into the descriptor bytes[15:8] and upon
> receiving the interrupt, if those bytes are overwritten by the hardware with
> the valid data, software also reads bytes[7:0] and executes receive/tx
> completion logic.
> 
> If the CPU executes the above two reads in out of order fashion, then the
> bytes[7:0] will have older data and causing the kernel panic.  We have to
> force the order of the reads and thus this patch introduces read memory
> barrier between these reads.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>

Applied, thanks.
