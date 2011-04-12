From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Be verbose when unable to load fw patch
Date: Tue, 12 Apr 2011 16:20:36 -0700 (PDT)
Message-ID: <20110412.162036.241924043.davem@davemloft.net>
References: <1302615172-1646-1-git-send-email-bp@amd64.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	borislav.petkov@amd.com, netdev@vger.kernel.org
To: bp@amd64.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302615172-1646-1-git-send-email-bp@amd64.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Borislav Petkov <bp@amd64.org>
Date: Tue, 12 Apr 2011 15:32:52 +0200

> From: Borislav Petkov <borislav.petkov@amd.com>
> 
> When the driver fails loading the firmware, it doesn't say which patch
> exactly it is missing. We have three different firmware images depending
> on the hw revision, so mention the exact patch name it is unable to load
> in the warning message.
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Borislav Petkov <borislav.petkov@amd.com>

Seems reasonable, Francois?
