From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 4/5] cgroup: net_cls: Pass in task to
 sock_update_classid()
Date: Fri, 26 Oct 2012 03:42:12 -0400 (EDT)
Message-ID: <20121026.034212.2155031388209196507.davem@davemloft.net>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
	<1351174619-5096-5-git-send-email-wagi@monom.org>
	<20121025184316.GD15105@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121025184316.GD15105-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 25 Oct 2012 14:43:17 -0400

> On Thu, Oct 25, 2012 at 04:16:58PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>> 
>> sock_update_classid() assumes that the update operation always are
>> applied on the current task. sock_update_classid() needs to know on
>> which tasks to work on in order to be able to migrate task between
>> cgroups using the struct cgroup_subsys attach() callback.
>> 
>> Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
 ...
> Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Applied.
