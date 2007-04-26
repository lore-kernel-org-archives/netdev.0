From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] [IPV4] nl_fib_lookup: Initialise res.r before fib_res_put(&res)
Date: Thu, 26 Apr 2007 20:11:29 +0400
Message-ID: <20070426161129.GB28053@ms2.inr.ac.ru>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org> <20070426052912.GA17402@kroah.com> <20070426194444.0f121293.vsu@altlinux.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za
To: Sergey Vlasov <vsu@altlinux.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:38787 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1031311AbXDZQNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:13:32 -0400
Content-Disposition: inline
In-Reply-To: <20070426194444.0f121293.vsu@altlinux.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> When CONFIG_IP_MULTIPLE_TABLES is enabled, the code in nl_fib_lookup()
> needs to initialize the res.r field before fib_res_put(&res) - unlike
> fib_lookup(), a direct call to ->tb_lookup does not set this field.

Indeed, I am sorry.

Alexey
