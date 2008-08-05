From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BUG:tg3_open() bug
Date: Tue, 05 Aug 2008 06:47:17 -0700
Message-ID: <1217944037.8694.3.camel@HP1>
References: <d82e647a0808050732u8c5343doba5cd7bc7248087c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ming Lei" <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761089AbYHERrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 13:47:55 -0400
In-Reply-To: <d82e647a0808050732u8c5343doba5cd7bc7248087c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-08-05 at 07:32 -0700, Ming Lei wrote:
> BUG: scheduling while atomic: ifconfig/3345/0x00000102

The patch to fix this has been applied to the net-2.6 tree last night:

tg3: Fix 'scheduling while atomic' errors


