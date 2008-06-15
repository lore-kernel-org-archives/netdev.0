From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert e100 driver to
	request_firmware()
Date: Sun, 15 Jun 2008 14:44:08 -0400
Message-ID: <485562F8.2000400@garzik.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>	
	<48555677.7040209@garzik.org>
	<3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinderlinux@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jaswinder Singh wrote:
> Hello Jeff,
> 
> On 6/15/08, Jeff Garzik <jeff@garzik.org> wrote:
>> David Woodhouse wrote:
>>> From: Jaswinder Singh <jaswinderlinux@gmail.com>
>>>
>>>  drivers/net/Kconfig                |    8 +
>>>  drivers/net/e100.c                 |  283
>>> +++++++++++-------------------------
>>>  firmware/Makefile                  |    2 +
>>>  firmware/WHENCE                    |   12 ++
>>>  firmware/e100/d101m_ucode.bin.ihex |   38 +++++
>>>  firmware/e100/d101s_ucode.bin.ihex |   38 +++++
>>>  firmware/e100/d102e_ucode.bin.ihex |   38 +++++
>>>  7 files changed, 222 insertions(+), 197 deletions(-)
>>>  create mode 100644 firmware/e100/d101m_ucode.bin.ihex
>>>  create mode 100644 firmware/e100/d101s_ucode.bin.ihex
>>>  create mode 100644 firmware/e100/d102e_ucode.bin.ihex
>> NAK - firmware should not be stored in a separate directory from the
>> driver to which it is intimately tied.
>>
> 
> driver source code will goto drivers directory and firmware will goto
> firmware directory.
> Please let us know, how can we keep them in same directory.

How?  It is simply a matter of changing the Makefile rules.

Each driver is _intimately_ tied to its firmware, so it only increases 
headaches by separating two pieces of a single, cohesive whole.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
