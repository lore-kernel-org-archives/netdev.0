From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1 net-next] ieee802154: fix __init functions
Date: Wed, 1 Oct 2014 07:34:39 +0200
Message-ID: <56FE06A5-5C2A-42E4-B01A-15EB36BAADE5@holtmann.org>
References: <1412141266-12258-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412141266-12258-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabian,

> Commit 3243acd37fd9
> ("ieee802154: add __init to lowpan_frags_sysctl_register")
> 
> added __init to lowpan_frags_ns_sysctl_register instead of
> lowpan_frags_sysctl_register
> 
> Suggested-by: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> net/ieee802154/reassembly.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)

when trying to apply this to bluetooth-next kernel, I am getting this:

Applying: ieee802154: fix __init functions
error: patch failed: net/ieee802154/reassembly.c:498
error: net/ieee802154/reassembly.c: patch does not apply
Patch failed at 0001 ieee802154: fix __init functions

Regards

Marcel
