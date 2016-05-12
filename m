From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline] qlcnic: potential NULL dereference in
 qlcnic_83xx_get_minidump_template()
Date: Wed, 11 May 2016 23:45:19 -0400 (EDT)
Message-ID: <20160511.234519.219883219155587882.davem@davemloft.net>
References: <20160510192004.GA30712@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160510192004.GA30712@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 10 May 2016 22:20:04 +0300

> If qlcnic_fw_cmd_get_minidump_temp() fails then "fw_dump->tmpl_hdr" is
> NULL or possibly freed.  It can lead to an oops later.
> 
> Fixes: d01a6d3c8ae1 ('qlcnic: Add support to enable capability to extend minidump for iSCSI')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
