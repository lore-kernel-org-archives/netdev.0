From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 13 Jun 2016 15:12:24 +0200
Message-ID: <3650675.mUADb08Tiz@wuerfel>
References: <1465686096-22156-1-git-send-email-henrik@austad.us> <20160613114713.GA9544@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160613114713.GA9544@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, June 13, 2016 1:47:13 PM CEST Richard Cochran wrote:
> * Kernel Space
> 
> 1. Providing frames with a future transmit time.  For normal sockets,
>    this can be in the CMESG data.  For mmap'ed buffers, we will need a
>    new format.  (I think Arnd is working on a new layout.)
> 

After some back and forth, I think the conclusion for now was that
the timestamps in the current v3 format are sufficient until 2106
as long as we treat them as 'unsigned', so we don't need the new
format for y2038, but if we get a new format, that should definitely
use 64-bit timestamps because that is the right thing to do.

	Arnd
