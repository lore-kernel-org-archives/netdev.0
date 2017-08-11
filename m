From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Fix null pointer dereference at mISDN_FsmNew
Date: Fri, 11 Aug 2017 14:56:35 -0700 (PDT)
Message-ID: <20170811.145635.1954762995141694287.davem@davemloft.net>
References: <1502456242-1695-1-git-send-email-vasilyev@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, geliangtang@gmail.com,
        johannes.berg@intel.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: vasilyev@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502456242-1695-1-git-send-email-vasilyev@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Vasilyev <vasilyev@ispras.ru>
Date: Fri, 11 Aug 2017 15:57:22 +0300

> If mISDN_FsmNew() fails to allocate memory for jumpmatrix
> then null pointer dereference will occur on any write to
> jumpmatrix.
> 
> The patch adds check on successful allocation and
> corresponding error handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Anton Vasilyev <vasilyev@ispras.ru>

Applied, thank you.
