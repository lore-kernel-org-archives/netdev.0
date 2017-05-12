From: Ravish Kumar <ravishk2004@gmail.com>
Subject: Re: Implementing Dynamic Rerouting in Kernel
Date: Fri, 12 May 2017 08:41:38 +0530
Message-ID: <CAEDnJmJZMaJ0bMO3X5gx7NE6jcDuE5zYnchrmSrftZmi_55ENw@mail.gmail.com>
References: <CAEDnJmKWYeEwB=cBKd-cOL+hmxe0U6G7CQ8Mkwc_eP5CpJVmbA@mail.gmail.com>
 <3b6e4d7b-0e35-5944-1200-6b0721afca82@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        mst@redhat.com, Jason@zx2c4.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b6e4d7b-0e35-5944-1200-6b0721afca82@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We do not want to add routes at run time rather i would prefer to have
a NetFilter driver which can intercept the packet and forward it to
desired interface.



On Thu, May 11, 2017 at 9:52 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 05/11/2017 02:59 AM, Ravish Kumar wrote:
>> Hi Experts,
>>
>> Need expert advice for the one of the requirement Where in VPN
>> solution we want to dynaically route the packets to different adapter.
>> We will manage our own DNS cache and , based on DNS to IP lookup, we
>> can redirect the packet either to Tun device or to a physical adapter.
>>
>> Please suggest some design what i need to do.
>
> What you are looking for can be done using ipset-dns from Jason:
>
> https://git.zx2c4.com/ipset-dns/about/
> --
> Florian
