From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tg3: fix return value check in tg3_read_vpd()
Date: Fri, 31 Dec 2010 12:31:16 -0800 (PST)
Message-ID: <20101231.123116.229747013.davem@davemloft.net>
References: <201012291417.24424.dsterba@suse.cz>
	<1293630031-27372-1-git-send-email-dsterba@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mchan@broadcom.com
To: dsterba@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293630031-27372-1-git-send-email-dsterba@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Sterba <dsterba@suse.cz>
Date: Wed, 29 Dec 2010 14:40:31 +0100

> Besides -ETIMEDOUT and -EINTR, pci_read_vpd may return other error
> values like -ENODEV or -EINVAL which are ignored due to the buggy
> check, but the data are not read from VPD anyway and this is checked
> subsequently with at most 3 needless loop iterations. This does not
> show up as a runtime bug.
> 
> CC: Matt Carlson <mcarlson@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: David Sterba <dsterba@suse.cz>

Applied, thanks.
