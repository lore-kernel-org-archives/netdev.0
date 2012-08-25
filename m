From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v2 05/10] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Sat, 25 Aug 2012 18:59:25 +0200
Message-ID: <5039046D.1040402@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org> <1345816904-21745-6-git-send-email-wagi@monom.org> <20120824232840.GS21325@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120824232840.GS21325-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25.08.2012 01:28, Tejun Heo wrote:
> On Fri, Aug 24, 2012 at 04:01:39PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> CGROUP_BUILTIN_SUBSYS_COUNT is used as start or stop point
>> when looping over the subsys array. Since the subsys array is
>> 64 entries long this is a good thing to do. Though we'd like
>> to reduce the array size considerable but we need to get rid
>> of CGROUP_BUILTIN_SUBSYS_COUNT to ease up the review process.
>
> Wouldn't it be better to explicitly state that a following patch would
> reduce the SUBSYS_COUNT and stop putting builtin and module ones into
> different sections?

Sure, can do that. I just to make sure I understand you correctly,
What do you mean with different section? Do you refer to the enum sorting?
