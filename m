From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH bluetooth-next] bluetooth: make bluetooth 6lowpan as an option
Date: Tue, 11 Mar 2014 07:56:52 -0700
Message-ID: <5D79FB52-77AC-4391-9CAB-6F792388EFD8@holtmann.org>
References: <1393924982-14001-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44230 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbaCKO5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 10:57:03 -0400
In-Reply-To: <1393924982-14001-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

> Currently you can have bluetooth 6lowpan without ipv6 enabled. This
> doesn't make any sense. With this patch you can disable/enable bluetooth
> 6lowpan support at compile time.
> 
> The current bluetooth 6lowpan implementation doesn't check the return
> value of 6lowpan function. Nevertheless I added -EOPNOTSUPP as return value
> if 6lowpan bluetooth is disabled.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> net/bluetooth/6lowpan.h | 21 +++++++++++++++++++++
> net/bluetooth/Kconfig   |  8 +++++++-
> net/bluetooth/Makefile  |  3 ++-
> 3 files changed, 30 insertions(+), 2 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
