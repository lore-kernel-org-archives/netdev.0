From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: avoid 0 sized arrays
Date: Tue, 24 Feb 2015 15:39:39 -0500 (EST)
Message-ID: <20150224.153939.917153133065621199.davem@davemloft.net>
References: <1424805277-7914-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nicolas.dichtel@6wind.com,
	jiri@resnulli.us, tgraf@suug.ch, jhs@mojatatu.com,
	roopa@cumulusnetworks.com, cwang@twopensource.com,
	daniel@iogearbox.net, netdev@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424805277-7914-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Tue, 24 Feb 2015 14:14:35 -0500

> Arrays (when not in a struct) "shall have a value greater than zero".
> 
> GCC complains when it's not the case here.
> 
> Fixes: ba7d49b1f0 ("rtnetlink: provide api for getting and setting slave info")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
