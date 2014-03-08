From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket buffer is large enough
Date: Fri, 07 Mar 2014 22:27:28 -0500
Message-ID: <5147229.ivUnbSCGlH@x2>
References: <7457128.6VP2v68V93@x2> <1394232722.17779.57.camel@flatline.rdu.redhat.com> <20140307.194801.1893514114998807038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: eparis@redhat.com, ebiederm@xmission.com, rgb@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-audit@redhat.com, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307.194801.1893514114998807038.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, March 07, 2014 07:48:01 PM David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Fri, 07 Mar 2014 17:52:02 -0500
> 
> > Audit is non-tolerant to failure and loss.
> 
> Netlink is not a loss-less transport.

Perhaps. But in all our testing over the years its been very good.

-Steve
