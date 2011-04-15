From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net-bonding: Fix minor/cosmetic type
 inconsistencies
Date: Thu, 14 Apr 2011 22:04:01 -0700 (PDT)
Message-ID: <20110414.220401.112603574.davem@davemloft.net>
References: <1302744151-12452-1-git-send-email-decot@google.com>
	<1302744151-12452-2-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302744151-12452-2-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

aFrom: David Decotigny <decot@google.com>
Date: Wed, 13 Apr 2011 18:22:30 -0700

> The __get_link_speed() function returns a u16 value which was stored
> in a u32 local variable. This patch uses the return value directly,
> thus fixing that minor type consistency.
> 
> The 'duplex' field in struct slave being encoded on 8 bits, to be more
> consistent we use a u8 integer (instead of u16) whenever we copy it to
> local variables.
> 
> Signed-off-by: David Decotigny <decot@google.com>

Applied.
