From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 07:40:58 +0100
Message-ID: <1392014458.21271.6.camel@linux-fkkt.site>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-10 at 00:06 +0100, Emil Goode wrote:
> The AX88772B occasionally send rx packets that cross urb boundaries
> and the remaining partial packet is sent with no hardware header.
> When the buffer with a partial packet is of less number of octets
> than the value of hard_header_len the buffer is discarded by the
> usbnet module. This is causing dropped packages and error messages
> in dmesg.
> 
> This can be reproduced by using ping with a packet size
> between 1965-1976.

Well, then how about simply removing the check?
It seems to have outlived its usefulness.

	Regards
		Oliver
