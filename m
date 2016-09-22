From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] BQL support and fix for a regression issue
Date: Thu, 22 Sep 2016 08:25:40 -0400 (EDT)
Message-ID: <20160922.082540.992436214283504080.davem@davemloft.net>
References: <1474535121-13958-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474535121-13958-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Thu, 22 Sep 2016 14:35:19 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> These patches add byte queue limit support and also fixes a regression
> issue introduced by commit
> 'net: thunderx: Use netdev's name for naming VF's interrupts'

The correct way to refer to commits when you fix a bug is
to use the "Fixes: " tag right before the signoffs and ACKs.

The correct form is:

Fixes: $SHA1_ID ("Commit header line.")

You'll see this in many other netdev commits.
