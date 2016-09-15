From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Thu, 15 Sep 2016 10:11:50 +0200
Message-ID: <0e64ec7a-e75f-620a-d7b7-e646913c3514@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <m3y42tlldz.fsf@neo.luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vincent Bernat <bernat-PWwKhitvBKI@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m3y42tlldz.fsf-PiWSfznZvZU/eRriIvX0kg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/15/2016 08:36 AM, Vincent Bernat wrote:
>  ❦ 12 septembre 2016 18:12 CEST, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org> :
> 
>> * The sample program learned to support both ingress and egress, and
>>   can now optionally make the eBPF program drop packets by making it
>>   return 0.
> 
> Ability to lock the eBPF program to avoid modification from a later
> program or in a subcgroup would be pretty interesting from a security
> perspective.

For now, you can achieve that by dropping CAP_NET_ADMIN after installing
a program between fork and exec. I think that should suffice for a first
version. Flags to further limit that could be be added later.


Thanks,
Daniel
