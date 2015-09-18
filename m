From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] atm: deal with setting entry before mkip was called
Date: Thu, 17 Sep 2015 22:13:54 -0700 (PDT)
Message-ID: <20150917.221354.1560252457487972419.davem@davemloft.net>
References: <1442431821-8217-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442431821-8217-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 16 Sep 2015 15:30:21 -0400

> If we didn't call ATMARP_MKIP before ATMARP_ENCAP the VCC descriptor is
> non-existant and we'll end up dereferencing a NULL ptr:
 ...
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
