From: "David S. Miller" <davem@davemloft.net>
Subject: Re: SIOCGIFMAP silently broken?
Date: Mon, 31 Jan 2005 11:46:40 -0800
Message-ID: <20050131114640.7e002652.davem@davemloft.net>
References: <41FE4745.4020003@fujitsu-siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Wilck <martin.wilck@fujitsu-siemens.com>
In-Reply-To: <41FE4745.4020003@fujitsu-siemens.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 15:57:09 +0100
Martin Wilck <martin.wilck@fujitsu-siemens.com> wrote:

> In both cases, the netdev->irq field isn't used anymore; perhaps it 
> should be officially deprecated and/or removed?

It is used for explicitly setting the IRQ value on hardware
where doing so automatically via probing may not be %100
reliable, such as on ISA.

Another way to do what you're trying to do is to look for
the string name of the device you are interested in within
the output of /proc/interrupts.
