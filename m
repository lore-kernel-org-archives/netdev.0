From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH bluetooth-next] bluetooth: make bluetooth 6lowpan as an
 option
Date: Tue, 11 Mar 2014 19:20:01 +0100
Message-ID: <20140311182000.GA11022@omega>
References: <1393924982-14001-1-git-send-email-alex.aring@gmail.com>
 <5D79FB52-77AC-4391-9CAB-6F792388EFD8@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:60099 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbaCKSUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 14:20:08 -0400
Content-Disposition: inline
In-Reply-To: <5D79FB52-77AC-4391-9CAB-6F792388EFD8@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

On Tue, Mar 11, 2014 at 07:56:52AM -0700, Marcel Holtmann wrote:
> Hi Alexander,
> 
> > Currently you can have bluetooth 6lowpan without ipv6 enabled. This
> > doesn't make any sense. With this patch you can disable/enable bluetooth
> > 6lowpan support at compile time.
> > 
> > The current bluetooth 6lowpan implementation doesn't check the return
> > value of 6lowpan function. Nevertheless I added -EOPNOTSUPP as return value
> > if 6lowpan bluetooth is disabled.
> > 
> > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > ---
> > net/bluetooth/6lowpan.h | 21 +++++++++++++++++++++
> > net/bluetooth/Kconfig   |  8 +++++++-
> > net/bluetooth/Makefile  |  3 ++-
> > 3 files changed, 30 insertions(+), 2 deletions(-)
> 
> patch has been applied to bluetooth-next tree.
> 

thanks and I see that next time I need to write:

"Bluetooth: ..." instead "bluetooth: ..."

Sorry, about that!

- Alex
