From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Wed, 16 Aug 2017 11:54:16 -0700 (PDT)
Message-ID: <20170816.115416.1591353514541788122.davem@davemloft.net>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170816.110635.1062040564700704290.davem@davemloft.net>
 <KL1P15301MB0008FB89237C3BB7A6D2BB39BF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, jasowang@redhat.com, georgezhang@vmware.com,
 sthemmin@microsoft.com, rolf.neugebauer@docker.com,
 marcelo.cerri@canonical.com, asias@redhat.com, dan.carpenter@oracle.com,
 olaf@aepfle.de, haiyangz@microsoft.com, dave.scott@docker.com,
 stefanha@redhat.com, apw@canonical.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, joe@perches.com,
 devel@linuxdriverproject.org, vkuznets@redhat.com, jhansen@vmware.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <KL1P15301MB0008FB89237C3BB7A6D2BB39BF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
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
Date: Wed, 16 Aug 2017 18:51:36 +0000

> It looks typically modern Linux distros have CONFIG_HYPERVISOR_GUEST=y
> by default

It doesn't matter what any distribution does or does not do.

People are going to do 'randconfig' builds over thousands and
thousands of configuration combinations to test your changes,
and those tests will fail.

> Do you want me to submit a v2 for this patch with the Kconfig change?

Of course, there is no way I can apply your series as-is.
