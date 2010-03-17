From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Tue, 16 Mar 2010 23:14:34 -0700 (PDT)
Message-ID: <20100316.231434.177653499.davem@davemloft.net>
References: <4BA07022.1040702@redhat.com>
	<20100316.225950.222623826.davem@davemloft.net>
	<4BA071BD.5040900@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA071BD.5040900@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Wed, 17 Mar 2010 14:07:57 +0800

> No, but silently accepting it as 0 is not correct, why don't
> reject it if it is not allowed?

You have to be careful even with that.  For example, if two
netconsoles are specified, seeing the space shouldn't
kill the first netconsole specification we parsed.

A warning perhaps, but outright rejection of all specifications is
really bad behavior.
