From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 13:11:44 -0700 (PDT)
Message-ID: <20140623.131144.199410086942856418.davem@davemloft.net>
References: <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623162911.GA20715@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 haiyangz@microsoft.com
To: greg@kroah.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140623162911.GA20715@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Mon, 23 Jun 2014 12:29:11 -0400

> Given that this change will fail on all future distro releases, and
> almost all of the community distros today, I don't see how this is
> acceptable at all.  Nor would it be any better if you switch to a
> systemd command line script as well.  You should just work like any
> other network device works in this situation when it comes to
> enabling/disabling the device.  Worse case, just tear down the whole
> network device at suspend time, and recreate it at resume.

Agreed, and I've strongly asked them to remove this code immediately.
