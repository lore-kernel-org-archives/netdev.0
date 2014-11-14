From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/7] bpf: add 'flags' attribute to
 BPF_MAP_UPDATE_ELEM command
Date: Fri, 14 Nov 2014 13:11:11 +0100
Message-ID: <1415967071.15154.9.camel@localhost>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
	 <1415929010-9361-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415929010-9361-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Do, 2014-11-13 at 17:36 -0800, Alexei Starovoitov wrote:
> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
> either update existing map element or create a new one.
> Initially the plan was to add a new command to handle the case of
> 'create new element if it didn't exist', but 'flags' style looks
> cleaner and overall diff is much smaller (more code reused), so add 'flags'
> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
>  #define BPF_ANY	0 /* create new element or update existing */
>  #define BPF_NOEXIST	1 /* create new element if it didn't exist */
>  #define BPF_EXIST	2 /* update existing element */

Would a cmpxchg-alike function be handy here?

Bye,
Hannes
