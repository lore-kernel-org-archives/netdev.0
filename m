From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [2.6 patch] prism54: make some functions static
Date: Sat, 30 Oct 2004 21:01:43 -0400
Message-ID: <20041031010143.GI7887@ruslug.rutgers.edu>
References: <20041030054534.GC4374@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Margit Schubert-While <margitsw@t-online.de>,
	prism54-private@prism54.org, netdev@oss.sgi.com, jgarzik@pobox.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20041030054534.GC4374@stusta.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 30, 2004 at 07:45:34AM +0200, Adrian Bunk wrote:
> As a side effect it turned out that the mgt_unlatch_all function was 
> completely unused, and I've therefore removed it.

mgt_unlatch_all is there as work in progress. We currently set ESSID to
commit but we may need more work than that depending on the mode we're
in. Even though we're not using it right now we may use it soon due to
WPA. Please don't remove it.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
