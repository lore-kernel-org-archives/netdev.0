From: Andy King <acking@vmware.com>
Subject: RE: [Pv-drivers] [vmxnet3] dma-debug warning message.
Date: Mon, 4 Aug 2014 16:49:17 +0000
Message-ID: <9319889501da4333b3b179826e78e80d@EX13-MBX-018.vmware.com>
References: <201408042002.IBE57329.JOHQFFOtLVFMOS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:48444 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbaHDQtZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 12:49:25 -0400
In-Reply-To: <201408042002.IBE57329.JOHQFFOtLVFMOS@I-love.SAKURA.ne.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tetsuo,

> vmxnet3 0000:03:00.0: DMA-API: device driver failed to check map error[device address=0x0000000049eb1f00] [size=6 bytes] [mapped as single]

Oops, you're right, we're not checking the return value. We'll send out a patch shortly to address this.

Thanks!
- Andy