From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v2] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Sun, 11 May 2014 22:35:40 +0000
Message-ID: <3fd83bc0e76c452386c15516a32c9cb3@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
 <20140508.164458.157597820665207475.davem@davemloft.net>
 <b641d25465f44cae8c7c9a680a31594d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>,
 <1399813625.11946.138.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1399813625.11946.138.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
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

> ________________________________________
> From: Ben Hutchings <ben@decadent.org.uk>
> Sent: Sunday, May 11, 2014 9:07 AM
> To: Haiyang Zhang
> I think most other drivers have a 1-1 mapping between hardware RX queues
> and the RX queue indices reported to Linux.  It appears that in this
> case sub_channel_index is the 'hardware' queue number, but you think
> there is not a 1-1 mapping.  Why is that?

Actually, it is 1-1 mapping. The number of channels equals to the number of
queues. In my updated patch (v3) the unnecessary "% ndev->real_num_rx_queues"
has been removed.

Thanks,
- Haiyang
