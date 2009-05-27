From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_cgroup: read classid atomically in classifier
Date: Tue, 26 May 2009 20:47:10 -0700 (PDT)
Message-ID: <20090526.204710.124271694.davem@davemloft.net>
References: <20090526195840.8464.36548.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizf@cn.fujitsu.com, akpm@linux-foundation.org, tgraf@suug.ch,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: menage@google.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759212AbZE0DrX@vger.kernel.org>
In-Reply-To: <20090526195840.8464.36548.stgit@menage.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Menage <menage@google.com>
Date: Tue, 26 May 2009 12:59:11 -0700

> cls_cgroup: read classid atomically in classifier
> 
> Avoid reading the unsynchronized value cs->classid multiple times,
> since it could change concurrently from non-zero to zero; this would
> result in the classifier returning a positive result with a bogus
> (zero) classid.
> 
> Signed-off-by: Paul Menage <menage@google.com>
> Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>

Patch applied, thanks!
