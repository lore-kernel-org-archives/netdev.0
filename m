From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Mon, 16 Jan 2017 22:15:51 +0200
Message-ID: <CALzJLG8h7oYPQrU5RK1j7zaNA0wvFOET55WvjMjZaoQqkmiDBQ@mail.gmail.com>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net> <20170113202932.GS20392@mtr-leonro.local>
 <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com>
 <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw@mail.gmail.com> <CALx6S35cSnMoBtxi+Eb_mH=LCLy9yY6U5sxofndce9r0eCs8+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALx6S35cSnMoBtxi+Eb_mH=LCLy9yY6U5sxofndce9r0eCs8+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2017 at 12:56 AM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
> On Fri, Jan 13, 2017 at 2:45 PM, Saeed Mahameed
> <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>> On Sat, Jan 14, 2017 at 12:06 AM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
>>> Btw, we did hit one issue in the backport. We started to get rx csum
>>> faults (checksum complete value indicates TCP checksum is bad, but
>>> host computation says checksum is good). I ran against 4.9 upstream
>>> kernel and do see these, however don't see them in 4.10. I haven't
>>> bisected yet. Is this a known issue?
>>>
>>
>> Not to me, I don't recall any csum related fixes or feature submitted
>> lately to mlx5,
>> Maybe something changed in the stack ?
>>
>> what configuration are you running ? what traffic ?
>>
> Nothing fancy. 8 queues and 20 concurrent netperf TCP_STREAMs trips
> it. Not a lot of them, but I don't think we really should ever see
> these errors.
>

Hi Tom

I've been trying to repro with no luck with kernel v4.9.
I am looking for checksum errors in dmesg, is that the place where you
saw the errors ?

can you dump the error in here ?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
