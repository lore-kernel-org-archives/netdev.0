From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid,
 gid, comm accessors
Date: Fri, 12 Jun 2015 17:26:17 -0700
Message-ID: <557B78A9.9060509@plumgrid.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com> <1434145226-17892-2-git-send-email-ast@plumgrid.com> <CALCETrUidQ9ig-xZrAFX8_==aVbDNKU-GfeYNMsT6uHugqSydg@mail.gmail.com> <557B60DB.5030200@plumgrid.com> <CALCETrVCAZkoM2TsrxgeT7d+kWjLrcRt76wiPav1Fk7wz0z-3g@mail.gmail.com> <557B6A00.7000600@plumgrid.com> <CALCETrVnhCoD9=nzDpB6UvmXyGz4Th_m1fstJDyRUKzfsSaKHw@mail.gmail.com> <557B6D74.2070305@plumgrid.com> <CALCETrU0OKoWKgxzUyi9A88Pm1VDfiCmgwbNycZoGbiHa6PzWA@mail.gmail.com> <557B718B.80604@plumgrid.com> <CALCETrWYHkBtVr5D0zdrXswoH2gSXsxhtD23w6J7EP=HEwPt8A@mail.gmail.com> <557B763F.7000003@plumgrid.com> <CALCETrWUuoZz2XOox5FJJPAfFdBakLnY1d7LLP5Uxq9tqgkpzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWUuoZz2XOox5FJJPAfFdBakLnY1d7LLP5Uxq9tqgkpzg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/12/15 5:24 PM, Andy Lutomirski wrote:
>> >so what specifically you proposing?
>> >Use from_kuid(&init_user_ns,...) instead?
> That seems reasonable to me.  After all, you can't install one of
> these probes from a non-init userns.

ok. will respin with that change.
