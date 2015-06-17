From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Wed, 17 Jun 2015 09:54:13 +0100
Message-ID: <1434531253.13744.254.camel@citrix.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
	 <5580821D.4080408@cogentembedded.com> <1434492550.2689.8.camel@perches.com>
	 <5580A33C.4040007@cogentembedded.com>
	 <1434498919.2689.35.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434498919.2689.35.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-06-16 at 16:55 -0700, Joe Perches wrote:
> 0x%x is easier and simpler to visualize than %#x.

They also don't produce the same output if the value is 0 (0x%x=>0x0, %
#x=>0), which can matter if you are trying to line up a column or
whatever.

Ian.
