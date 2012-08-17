From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v0 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Fri, 17 Aug 2012 09:55:27 +0200
Message-ID: <502DF8EF.1070202@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org> <1345126336-20755-4-git-send-email-wagi@monom.org> <502DF43F.9010209@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <502DF43F.9010209-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17.08.2012 09:35, Li Zefan wrote:
>> +#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
>> +extern struct static_key cgroup_cls_enabled;
>> +#define clscg_enabled static_key_false(&cgroup_cls_enabled)
>> +#endif
>> +
> 
> If it's built-in, clscg_enabled is always true (after we call cgroup_subsys_init at
> boot), so we don't need jump label at all.

Okay. I'll update the patches so that only the module built contain the
jump labels.

daniel
