From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: ipv6, remove unnecessary check
Date: Sun, 10 Jan 2010 13:28:06 -0800 (PST)
Message-ID: <20100110.132806.177106798.davem@davemloft.net>
References: <20100110103528.GA4769@x200>
	<1263120183-16365-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753965Ab0AJV17@vger.kernel.org>
In-Reply-To: <1263120183-16365-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Sun, 10 Jan 2010 11:43:03 +0100

> Stanse found a potential null dereference in snmp6_unregister_dev.
> There is a check for idev being NULL, but it is dereferenced
> earlier. But idev cannot be NULL when passed to
> snmp6_unregister_dev, so remove the test.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied.
