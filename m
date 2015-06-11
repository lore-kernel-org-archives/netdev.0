From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] cn_proc: Flag termination of the last thread in the process
Date: Thu, 11 Jun 2015 18:26:07 +0300
Message-ID: <1052831434036367@web13o.yandex.ru>
References: <1432929029-2205-1-git-send-email-sfzhi@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Zhirikov <sfzhi-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432929029-2205-1-git-send-email-sfzhi-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sergei

29.05.2015, 22:50, "Sergei Zhirikov" <sfzhi-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>:
> There is no easy and reliable way for userspace to get notified
> of a process termination. The process connector sends out "exit"
> events upon termination of each thread, but it is not trivial for
> userspace to tell whether the just-terminated thread was the last
> one in the process.
>
> With this change a flag will be set in struct cn_proc for the exit
> event of the last thread in the process.

I have no objection against this patch, but it should really go through cn_proc maintainer.
Feel free to add my Acked-by.
