From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH] cgroup: net_cls: Include missing header with sock_update_classid()
 definition
Date: Fri, 14 Sep 2012 16:50:18 +0200
Message-ID: <5053442A.7040801@monom.org>
References: <1347633184-26837-1-git-send-email-wagi@monom.org> <1347633184-26837-3-git-send-email-wagi@monom.org> <CA+icZUUrdGgUM32r88EyRHEb3Q6bULqnk74PikQ8A9q25ZA3NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Rick Jones <rick.jones2-VXdhtT5mjnY@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUUrdGgUM32r88EyRHEb3Q6bULqnk74PikQ8A9q25ZA3NA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sedat,

On 14.09.2012 16:43, Sedat Dilek wrote:
> On Fri, Sep 14, 2012 at 4:33 PM, Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org> wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> commit 1f66c0a8833c3974ab6b35edcf4f8585b2f94592
>> Author: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>> Date:   Wed Sep 12 16:12:01 2012 +0200
>>
>>      cgroup: net_cls: Move sock_update_classid() declaration to cls_cgroup.h
>>
>> Claimed that there was only net/socket.c depending on
>> sock_update_class(). That is not true drivers/net/tun.c needs to
>> include the cls_cgroup.h header too.
>>
>> Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
>> Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>> Cc: Rick Jones <rick.jones2-VXdhtT5mjnY@public.gmane.org>
>> Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> ---
>>
>> This version is on top of the latest cgroup for-3.7 branch.
>>
>
> Thanks for the quick fix.

No problem. I am still ashamed not finding it myself.

> Please honour Reported-by: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>.

Sure, will do next time.

> If this is the fix for the breakage in today's Linux-Next
> (next-20120914), please add a "-next" to the subject next time.

Correct, this one is for linux-next but I got the impression that cgroup 
for-3.7 branch was ignored because of this. Therefore I have send two 
versions. Hmm, I'll need to check the results of todays next tree.

thanks,
daniel
