From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] testptp: Silence compiler warnings on ppc64
Date: Tue, 29 Sep 2015 21:17:14 -0700 (PDT)
Message-ID: <20150929.211714.402151449882462113.davem@davemloft.net>
References: <1443541528-937-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org, corbet@lwn.net,
	linux-doc@vger.kernel.org, trivial@kernel.org
To: thuth@redhat.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1443541528-937-1-git-send-email-thuth@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Huth <thuth@redhat.com>
Date: Tue, 29 Sep 2015 17:45:28 +0200

> When compiling Documentation/ptp/testptp.c the following compiler
> warnings are printed out:
 ...
> This happens because __s64 is by default defined as "long" on ppc64,
> not as "long long". However, to fix these warnings, it's possible to
> define the __SANE_USERSPACE_TYPES__ so that __s64 gets defined to
> "long long" on ppc64, too.
> 
> Signed-off-by: Thomas Huth <thuth@redhat.com>

Applied, thanks.
