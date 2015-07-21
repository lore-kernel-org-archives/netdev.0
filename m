From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Tue, 21 Jul 2015 15:07:42 +0200
Message-ID: <1437484062.3823.7.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55AD3A41.2040100@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
> Races on dev->rx_qlen. Reproduced these by repeatedly changing MTU
> (1500 
> <-> 1400) while downloading large files.

Hi,

I don't see how it matters much. The number of buffers is just
an optimization. As long as it eventually is corrected I don't
see harm.

	Regards
		Oliver
