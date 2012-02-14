From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [PATCH 1/1] usb: cdc-ncm: Increase maximum allowed datagram size
Date: Tue, 14 Feb 2012 23:27:29 +0100
Message-ID: <CAL_Kpj0VSu-ByUEwTeVG5-5psab3h38bTL=ot7vYD8A+Oeb_Ug@mail.gmail.com>
References: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com>
	<20120214.144622.678577766818888054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: oliver@neukum.name, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, toby.gray@realvnc.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120214.144622.678577766818888054.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2012 at 8:46 PM, David Miller <davem@davemloft.net> wrote:
>
> Can a USB expert please sanity check this before I apply it?

I would recommend to change CDC_NCM_NTB_MAX_SIZE_TX(RX) to 32K and
simply set MAX_DATAGRAM_SIZE to 16K

/alexey
