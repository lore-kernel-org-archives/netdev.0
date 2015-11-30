From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Sun, 29 Nov 2015 22:45:57 -0500 (EST)
Message-ID: <20151129.224557.1010909057566457373.davem@davemloft.net>
References: <1448459081-6427-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448459081-6427-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Wed, 25 Nov 2015 14:44:41 +0100

> The simple_strtol function is obsolete.
> This patch replace it by kstrtoint.
> This will simplify code, since some error case not handled by
> simple_strtol are handled by kstrtoint.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

kstrtoint() actually returns an accurate error code, so please
use it.
