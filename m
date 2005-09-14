From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] gt96100: stop using pci_find_device()
Date: Wed, 14 Sep 2005 20:40:38 +0100
Message-ID: <20050914194038.GP3224@linux-mips.org>
References: <20050914185136.GE19491@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20050914185136.GE19491@mipter.zuzino.mipt.ru>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2005 at 10:51:37PM +0400, Alexey Dobriyan wrote:

> Replace pci_find_device with pci_get_device/pci_dev_put to plug race
> with pci_find_device.

The system is a little odd; the race condition probably doens't exist on
this particular chipset.

  Ralf
