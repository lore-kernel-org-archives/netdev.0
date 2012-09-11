From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 23:39:33 +0200
Message-ID: <504FAF95.5000808@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org> <1347380774-9546-8-git-send-email-wagi@monom.org> <20120911210109.GZ7677@google.com> <20120911210821.GB7677@google.com> <504FADC1.4060503@monom.org> <20120911213646.GF7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120911213646.GF7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 09/11/2012 11:36 PM, Tejun Heo wrote:
> On Tue, Sep 11, 2012 at 11:31:45PM +0200, Daniel Wagner wrote:
>>> Oops, that was wrong.  net_prio_subsys_id itself becomes constant.
>>> Let's please better explain why the RCU trick removal is safe then.
>>
>> In the last paragraph in the commit message I tried to document why
>> it is safe to remove the RCU trick. Not good enough?
>
> It isn't clear to me why it was necessary before and why it now
> becomes unnecessary.  It states what the code does and that it's no
> longer necessary but I'd really like more elaboration.

Got it. I'll try to document then why it was necessary before. I'll add 
then also the original author of those lines to the Cc list just in case 
I get it wrong.

cheers,
daniel
