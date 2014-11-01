From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: fix possible memory leak
Date: Sat, 01 Nov 2014 15:12:44 -0400 (EDT)
Message-ID: <20141101.151244.1626989876697579410.davem@davemloft.net>
References: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414841374-30537-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Sat,  1 Nov 2014 16:59:34 +0530

> we are allocating memory using kzalloc for struct mvpp2_prs_entry,
> but later when we are getting error we were just returning the error
> value without releasing the memory.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied, thanks.
