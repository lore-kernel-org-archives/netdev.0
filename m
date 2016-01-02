From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 4/9] Drivers: hv: ring_buffer: enhance
 hv_ringbuffer_read() to support hvsock
Date: Fri, 01 Jan 2016 23:29:52 -0500 (EST)
Message-ID: <20160101.232952.740480728119960077.davem@davemloft.net>
References: <1450966476-13175-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 stephen@networkplumber.org, stefanha@redhat.com, netdev@vger.kernel.org,
 apw@canonical.com, pebolle@tiscali.nl, dan.carpenter@oracle.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1450966476-13175-1-git-send-email-decui@microsoft.com>
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
Date: Thu, 24 Dec 2015 06:14:36 -0800

> +#define HV_RINGBUFFER_READ_FLAG_RAW		(1 << 0)
> +#define HV_RINGBUFFER_READ_FLAG_HVSOCK		(1 << 1)

Please use BIT().
