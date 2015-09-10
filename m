From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: Fix sleeping function called during
 get_stats64
Date: Wed, 09 Sep 2015 20:31:47 -0700 (PDT)
Message-ID: <20150909.203147.2009094422078807401.davem@davemloft.net>
References: <1441833400-2677-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	pomidorabelisima@gmail.com, konrad@kernel.org,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: vinschen@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441833400-2677-1-git-send-email-vinschen@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corinna Vinschen <vinschen@redhat.com>
Date: Wed,  9 Sep 2015 23:16:40 +0200

> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
> Fixes: 6e85d5ad36a26debc23a9a865c029cbe242b2dc8
> 
> Based on the discussion starting at
> http://www.spinics.net/lists/netdev/msg342193.html
> 
> Tested locally on RTL8168evl/8111evl with various concurrent processes
> accessing /proc/net/dev while changing the link state as well as
> removing/reloading the r8169 module.
> 
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>

Please address Francois's minor feedback, camelcase drives me nuts
too FWIW :-)
