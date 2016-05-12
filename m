From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re:  [PATCH 0/6] hv_netvsc: avoid races on mtu change/set channels
Date: Thu, 12 May 2016 18:19:07 +0200
Message-ID: <trinity-178386d6-a968-4eac-9cf5-fcd34aad7a2a-1463069947179@3capp-gmx-bs05>
References: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
 <trinity-ccc16f5c-6580-4594-a0d0-c7b07bf2f7a6-1463065112147@3capp-gmx-bs05>,
 <87r3d7mhy3.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: "Vitaly Kuznetsov" <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87r3d7mhy3.fsf@vitty.brq.redhat.com>
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


> It's worse: before the patch series we get 'struct hv_device' (as it is
> called from core VMBus code and we simply cannot get to 'struct
> net_device' we need without traveling through 'struct
> netvsc_device'. This structure is removed and re-created by both
> netvsc_set_channels() and netvsc_change_mtu().


Ah ok, I missed that we cant rely on getting a valid netdev from the hv_device in 
remove. Thanks for the explanation!

Regards,
Lino
