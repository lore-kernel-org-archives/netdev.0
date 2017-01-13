From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Fri, 13 Jan 2017 15:07:51 -0800
Message-ID: <CALx6S34zw7S+8rB9nuBtbzZ6JkcVreHTwJZrXftHdfmKLF3knQ@mail.gmail.com>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net> <20170113202932.GS20392@mtr-leonro.local>
 <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com>
 <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw@mail.gmail.com>
 <CALx6S35cSnMoBtxi+Eb_mH=LCLy9yY6U5sxofndce9r0eCs8+w@mail.gmail.com> <10e998b7-0008-2f26-2874-57ec61c8cacb@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rick Jones <rick.jones2-ZPxbGqLxI0U@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <10e998b7-0008-2f26-2874-57ec61c8cacb-ZPxbGqLxI0U@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2017 at 2:59 PM, Rick Jones <rick.jones2-ZPxbGqLxI0U@public.gmane.org> wrote:
> On 01/13/2017 02:56 PM, Tom Herbert wrote:
>>
>> On Fri, Jan 13, 2017 at 2:45 PM, Saeed Mahameed
>>>
>>> what configuration are you running ? what traffic ?
>>>
>> Nothing fancy. 8 queues and 20 concurrent netperf TCP_STREAMs trips
>> it. Not a lot of them, but I don't think we really should ever see
>> these errors.
>
>
> Straight-up defaults with netperf, or do you use specific -s/S or -m/M
> options?
>
./super_netperf_tput 20 -H test001 -l 100 -t TCP_STREAM

> happy benchmarking,
>
> rick jones
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
