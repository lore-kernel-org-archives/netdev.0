From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 8/9] net: filter: rework/optimize internal
 BPF interpreter's instruction set
Date: Tue, 25 Mar 2014 20:46:28 -0400 (EDT)
Message-ID: <20140325.204628.1622839093852736075.davem@davemloft.net>
References: <1395749457-16178-9-git-send-email-dborkman@redhat.com>
	<20140325.201712.1651156258234145348.davem@davemloft.net>
	<53321E3B.8080709@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, ast@plumgrid.com, netdev@vger.kernel.org,
	hagen@jauu.net, keescook@chromium.org, pmoore@redhat.com,
	mingo@kernel.org, linux-kernel@vger.kernel.org
To: hpa@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53321E3B.8080709@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H. Peter Anvin" <hpa@linux.intel.com>
Date: Tue, 25 Mar 2014 17:24:27 -0700

> If you allow loops, it greatly increases the expressibility of the
> language, but we would really need another control to limit CPU usage.

We don't want super expressibility.

We want an extremely simple, trivial to validate, filtering language.
