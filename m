From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] DM9000B: driver initialization upgrade
Date: Sun, 31 Mar 2013 19:45:01 -0400 (EDT)
Message-ID: <20130331.194501.2152753313602353257.davem@davemloft.net>
References: <1364548422-3051-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@virginia.edu, matthew@mattleach.net,
	gregkh@linuxfoundation.org, joseph_chang@davicom.com.tw,
	jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: josright123@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364548422-3051-1-git-send-email-josright123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph CHANG <josright123@gmail.com>
Date: Fri, 29 Mar 2013 17:13:42 +0800

> Fix bug for DM9000 revision B which contain a DSP PHY
> 
> DM9000B use DSP PHY instead previouse DM9000 revisions' analog PHY,
> So need extra change in initialization, For
> explicity PHY Reset and PHY init parameter, and
> first DM9000_NCR reset need NCR_MAC_LBK bit by dm9000_probe().
> 
> Following DM9000_NCR reset cause by dm9000_open() clear the
> NCR_MAC_LBK bit.
> 
> Without this fix, Power-up FIFO pointers error happen around 2%
> rate among Davicom's customers' boards. With this fix, All above
> cases can be solved.
> 
> Signed-off-by: Joseph CHANG <josright123@gmail.com>

Applied.
