From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 08/11] net: bluetooth: change the len parameter of sco_send_frame() to size_t
Date: Mon, 26 Oct 2015 04:54:03 +0900
Message-ID: <342E581E-BA14-44A1-95A5-B377A226A226@holtmann.org>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com> <1445602236-24130-9-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44541 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbJYTyN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 15:54:13 -0400
In-Reply-To: <1445602236-24130-9-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Corentin,

> len is used in operation/function that wait for unsigned value.
> Furthermore the only one call of sco_send_frame give a size_t as argument.
> So the parameter need to be set as size_t.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
> ---
> net/bluetooth/sco.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

I am not taking this patch until you also fix the kbuild test robot reported issue with format print modifier for size_t.

Regards

Marcel
