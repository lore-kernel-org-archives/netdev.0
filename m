From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH v2 4/5] net: thunderx: Switchon carrier only upon interface
 link up
Date: Wed, 02 Dec 2015 14:30:37 +0300
Message-ID: <011f01d12cf4$de8bc7c0$9ba35740$@samsung.com>
References: <1449050777-37836-1-git-send-email-sunil.kovvuri@gmail.com>
 <1449050777-37836-5-git-send-email-sunil.kovvuri@gmail.com>
 <00ec01d12cee$26a28a00$73e79e00$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <00ec01d12cee$26a28a00$73e79e00$@samsung.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello again!

> Subject: RE: [PATCH v2 4/5] net: thunderx: Switchon carrier only upon interface link up
> 
>  Just a reminder, we have issue with this one too, which is not addressed yet.

 I have examined the problem thoroughly and discovered that it is a problem with experimental BGX driver patches on my 4.2 host
kernel build. It fails to send NIC_MBOX_MSG_BGX_LINK_CHANGE, so nothing works.
 I have retested this series on top of 4.3 running on ThunderX. It has good BGX driver and everything works fine. Therefore, the
whole series can be safely applied and...

 Tested-by: Pavel Fedin <p.fedin@samsung.com>

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
