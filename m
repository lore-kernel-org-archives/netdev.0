From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 2/4] hv_netvsc: protect nvdev->extension with RCU
Date: Thu, 02 Nov 2017 11:27:36 +0100
Message-ID: <87375xug9z.fsf@vitty.brq.redhat.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
 <20171031134204.15287-3-vkuznets@redhat.com>
 <20171031174451.096978cd@shemminger-XPS-13-9360>
 <87shdzw889.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87shdzw889.fsf@vitty.brq.redhat.com> (Vitaly Kuznetsov's message
 of "Tue, 31 Oct 2017 18:13:58 +0100")
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

Vitaly Kuznetsov <vkuznets@redhat.com> writes:

>
> Ok, I may have missed something. I'll try reproducing the crash and
> finding a better fine-grained solution.
>

It's been two days and I'm failing to reproduce the crash in
rndis_filter_receive() in my environment so I'll probably just re-send
patches 1 and 4 of this series as v2.

-- 
  Vitaly
