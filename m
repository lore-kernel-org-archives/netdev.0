From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 4 Dec 2015 02:10:50 +0100
Message-ID: <20151204011050.GC26934@lunn.ch>
References: <561FF9E2.30102@opensource.altera.com>
 <56200687.9040903@gmail.com>
 <562005AD.8020903@opensource.altera.com>
 <56200BD7.8020505@gmail.com>
 <20151203204811.GB14427@amd>
 <5660B2EC.1050705@caviumnetworks.com>
 <5660CD87.5050603@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Pavel Machek <pavel@denx.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5660CD87.5050603@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > FWIW: My initial patch to address the failure worked with the original DTB.
> 
> Can I ask what patch are you referring to? I was sidetracked for a while
> on this issue, but I still see it failing as of v4.4-rc3. I'll try to
> get back to debugging this.

Hi Dinh

There are two different patches:

https://lkml.org/lkml/2015/10/16/669

and

https://www.mail-archive.com/netdev@vger.kernel.org/msg83183.html

Although the first one works, it keeps searching up and up and up, so
you could in theory put the phy properties a lot higher than the MAC.

The second patch restricts where it looks for the phy properties to
only the MAC. But it does not work. We would like to understand why it
does not work.

     Andrew
