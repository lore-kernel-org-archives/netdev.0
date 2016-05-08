From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Sun, 08 May 2016 13:45:00 -0400 (EDT)
Message-ID: <20160508.134500.680661474744275849.davem@davemloft.net>
References: <BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160507.134048.139772599380708393.davem@davemloft.net>
 <BLUPR03MB141044B2FC50DE43401C8C17BF7F0@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BLUPR03MB141044B2FC50DE43401C8C17BF7F0@BLUPR03MB1410.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Sun, 8 May 2016 06:11:04 +0000

> Thanks for pointing this out!
> I understand, so I think I should add a module parameter, e.g.,
> "hv_sock.max_socket_number" with a default value, say, 1024?

No, you should get rid of the huge multi-page buffers.
