From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Using 802.11x wireless usb device on MIPS platform
Date: Tue, 9 Jan 2007 14:09:31 +0000
Message-ID: <20070109140931.GB6614@linux-mips.org>
References: <1cf601c73399$2ab7cd10$106215ac@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf1.mips-uk.com ([194.74.144.154]:47562 "EHLO
	dl5rb.ham-radio-op.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932104AbXAIOIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 09:08:49 -0500
To: colin <colin@realtek.com.tw>
Content-Disposition: inline
In-Reply-To: <1cf601c73399$2ab7cd10$106215ac@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 10:52:14AM +0800, colin wrote:

> I have used two 802.11x wireless usb devices successfully on MIPS platform.
> One is realtek 8187 and the other one is ralink 2571.
> I would like to put them into kernel tree and then I found that there are
> not many 802.11x devices supported in Linux.

If you want to submit a driver to the kernel, please post it to
netdev@vger.kernel.org.  Don't expect a driver to be just accepted; it
will go through a thorough review and after all the issues have been
resolved it will be accepted.

> Moreover, there is no any wireless usb device supported.

Wireless support under Linux is suffering from several problems:

 o some core require microcode to be loaded but the vendor does not
   give such permission.
 o lack of documentation, sometimes for paranoid or bogus legal reasons or
   "intellectual property" concerns.

At times it really seems vendors are working to maximize pain for the user ...

> It is also very strange that 8187 and 2571 both have their own ieee802.11x
> stack and crypt drivers. It seems that Linux doesn't offer them.
> I am wondering why Linux is so complex in 802.11x.

Well, for one thing because 802.11 is complex.  The Linux wireless support
has gone through several generations; some of the wireless work was for
one or the other reason never integrated in the kernel.org kernel.

  Ralf
