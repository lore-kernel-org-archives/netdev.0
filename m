From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [6/14] Orinoco driver updates - cleanup PCI initialization
Date: Wed, 23 Feb 2005 23:35:05 -0500
Message-ID: <421D5979.5080600@pobox.com>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: David Gibson <hermes@gibson.dropbear.id.au>
In-Reply-To: <20050224035957.GH32001@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FYI, pci_set_drvdata() needs to be one of the last functions called 
during PCI ->probe().

	Jeff
