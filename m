From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] bpf: share helpers between tracing and
 networking
Date: Mon, 15 Jun 2015 20:28:51 -0700
Message-ID: <557F97F3.6060400@plumgrid.com>
References: <1434163154-5218-1-git-send-email-ast@plumgrid.com> <20150615.160130.583783771772303463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150615.160130.583783771772303463.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/15/15 4:01 PM, David Miller wrote:
>
> Although I agree with the sentiment that this thing can cause
> surprising results and can be asking for trouble.
>
> If someone wants to filter traffic "by UID" they might make
> a simple ingress TC ebpf program using these new interfaces
> and expect it to work.
>
> But the UID their program will see will be the UID of whatever
> randomly happened to be executing when the packet was received
> and processed.

yes, you're right. Such tc filters will be incorrect.
Will send a partial revert disallowing them in tc.
