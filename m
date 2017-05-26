From: Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 26 May 2017 14:31:48 -0400
Message-ID: <f47d7519-4f58-bc94-2387-20342afd91b8@fb.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
 <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
 <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/26/2017 04:29 AM, Saeed Mahameed wrote:
> On Thu, May 25, 2017 at 11:48 PM, Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org> wrote:
>> On 05/25/2017 06:40 AM, Saeed Mahameed wrote:
> Hi Jes,
> 
> No, It is clearly stated in the commit message :
> 
> "The FPGA is a bump-on-the-wire and thus affects operation of
> the mlx5_core driver on the ConnectX ASIC."
> 
> Which means mlx5 FPGA user can only write logic which affects only
> packets going in/out
> A ConnectX chip - so it is only network stuff -.
> 
>> We have this with other devices in the kernel where a primary device driver
>> provides an interface for an additional sub-driver to access another device
>> behind it. Like bt-coexist in some of the wifi drivers allowing access to a
>> bluetooth device behind it.
> 
> Blutooth over wifi or vise versa is a very good example to what you
> are requesting.
> But, it doesn't fit to what we are trying to do here. mlx5 FGPA is a
> ConnectX card feature, not a new protocol.

In that case it would need to be an optional module that can be enabled 
or disabled at build time.

Cheers,
Jes


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
