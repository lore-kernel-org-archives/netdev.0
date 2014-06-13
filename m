From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v2 0/2] rt2800usb: Fix support for USB 057c:8501
Date: Fri, 13 Jun 2014 15:08:17 +0200
Message-ID: <20140613130816.GA2211@redhat.com>
References: <20140612173057.15935.14194.stgit@charlie.fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	netdev@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140612173057.15935.14194.stgit@charlie.fem.tu-ilmenau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2014 at 07:33:31PM +0200, Michael Braun wrote:
> v2: fix endianness and coding style. Using rt2x00usb_register_read does not work for me.

I missed that it use USB_MULTI_READ request and you need
USB_DEVICE_MODE instead, sorry.

Stanislaw
