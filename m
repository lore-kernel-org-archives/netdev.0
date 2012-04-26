From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: Re: [PATCH] mISDN: Ignore return value of driver_for_each_device in
 function hfcpci_softirq.
Date: Thu, 26 Apr 2012 16:08:44 +0100
Message-ID: <CAC52Y8Z_QpnVA37i1GYTWdx5sydVCcke+7dbVx=pCftT3=P5nw@mail.gmail.com>
References: <1335309230-23428-1-git-send-email-krzysztof.wilczynski@linux.com> <20120425.204231.1586199621022282253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: isdn@linux-pingi.de, gregkh@linuxfoundation.org,
	horms@verge.net.au, trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120425.204231.1586199621022282253.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[...]
> I'm not applying this, at least not with a more intelligent analysis
> of why any error or other non-zero value signalled by
> driver_for_each_device should be completely ignored, and no error
> handling should be performed.

This is a fair point.  It should not be ignored.  I was looking through
the code and found few cases where the return value was not checked
for potential errors (I assume that it was collected to avoid warning being
produced, but that was about it) without printing an error message.

The following could most certainly use better error reporting concerning
use of driver_for_each_device:

drivers/isdn/hardware/mISDN/hfcpci.c
drivers/media/video/cx18/cx18-alsa-main.c
drivers/media/video/ivtv/ivtvfb.c

I will look into it making suitable changes.  Thanks for pointing it
out to me! :)

KW
