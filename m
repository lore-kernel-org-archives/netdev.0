From: "David S. Miller" <davem@davemloft.net>
Subject: Re: eepro100 broken on ARM by 2.6.11-rc1 changes
Date: Tue, 15 Feb 2005 13:20:47 -0800
Message-ID: <20050215132047.7a33e6ec.davem@davemloft.net>
References: <20050215211020.GB566@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050215211020.GB566@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 22:10:20 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> eepro100 seems to have stopped working between 2.6.10 and 2.6.11-rc2
> on an embedded ARM platform.  In 2.6.10 I would see this:

Please check to make sure ARM implements pci_iomap(), ioread*()/iowrite*()
and friends correctly.  eepro100 is one of the few net drivers that makes
use of this newer API, and the conversion to using this new API occured
post 2.6.10
