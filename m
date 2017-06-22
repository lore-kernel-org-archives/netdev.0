From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] netxen: Fix a sleep-in-atomic bug in
 netxen_nic_pci_mem_access_direct
Date: Thu, 22 Jun 2017 09:08:10 +0300
Message-ID: <20170622060809.jvnuewiicuwtlzb4@mwanda>
References: <1497840533-4894-1-git-send-email-baijiaju1990@163.com>
 <20170620.133530.1607963470682255531.davem@davemloft.net>
 <87d19xooo0.fsf@purkki.adurom.net>
 <594A131F.9040300@163.com>
 <8737atv4pm.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jia-Ju Bai <baijiaju1990@163.com>,
        David Miller <davem@davemloft.net>, manish.chopra@cavium.com,
        rahul.verma@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8737atv4pm.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should probably add a might_sleep() to ioremap() to prevent these
bugs in the future.

This bug is eight years old.  You can report it, but it's going to hard
to get anyone to fix it.  I sometimes ignore ancient bugs.  On the other
hand, netxen is fairly well supported so it doesn't hurt to try.

I try to report bugs as soon as they are introduced.  I report it to
the author and CC the relevant list.  If people don't respond to my
email after a month then I complain again.

regards,
dan carpenter
