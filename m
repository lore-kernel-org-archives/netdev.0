From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Fri, 07 Mar 2014 19:48:01 -0500 (EST)
Message-ID: <20140307.194801.1893514114998807038.davem@davemloft.net>
References: <7457128.6VP2v68V93@x2>
	<87wqg8zfj4.fsf@xmission.com>
	<1394232722.17779.57.camel@flatline.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, sgrubb@redhat.com, rgb@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-audit@redhat.com, akpm@linux-foundation.org
To: eparis@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394232722.17779.57.camel@flatline.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Fri, 07 Mar 2014 17:52:02 -0500

> Audit is non-tolerant to failure and loss.

Netlink is not a loss-less transport.
