From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Thu, 26 Jun 2003 23:07:27 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030626.230727.35666164.davem@redhat.com>
References: <3EF9D5C2.5080101@us.ibm.com>
	<20030625.234251.116353369.davem@redhat.com>
	<3EFB2017.5030202@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3EFB2017.5030202@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Thu, 26 Jun 2003 09:32:23 -0700

I still have problems with this patch.
   
   -#define	RTM_MAX		(RTM_BASE+31)
   +#define	RTM_GETLNKFLAGS	(RTM_BASE+34)
   +
   +#define	RTM_GETPLIST	(RTM_BASE+38)

Please allocate contiguous numbers to the new messages, don't skip
around like this.

Thanks.  (this of course means you have to redo your 2.4.x patch
as well)
