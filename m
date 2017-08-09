From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Wed, 9 Aug 2017 07:41:43 -0700
Message-ID: <20170809074143.123938ee@xeon-e3>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
 <87ziba9mwj.fsf@vitty.brq.redhat.com>
 <20170808081506.38bea86c@xeon-e3>
 <87shh29j70.fsf@vitty.brq.redhat.com>
 <20170808082927.128362aa@xeon-e3>
 <87mv7a9ict.fsf@vitty.brq.redhat.com>
 <20170808085354.4208a612@xeon-e3>
 <87r2wlxgdy.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 sthemmin@microsoft.com, netdev@vger.kernel.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87r2wlxgdy.fsf@vitty.brq.redhat.com>
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

On Wed, 09 Aug 2017 11:03:05 +0200
Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> Stephen Hemminger <stephen@networkplumber.org> writes:
> 
> > The following would allow udev a chance at the device.
> >  
> 
> This would of course work but the approach is a bit hackish and can
> still fail on a loaded system. Raising the pause interval would be an
> option, but again, probably not the best one.
> 
> Let me try to send an RFC removing the check it dev_change_name() and if
> it turns out that it can't be removed we can go back to your patch. But
> in case it can we can leave without it.
> 
> Thanks,

I don't want to require change of semantics of core networking code
for one driver. Changing name of up device has been blocked for so
long that allowing it might break existing userspace apps. It might
be ok in the future, but netvsc needs to work without that change.
