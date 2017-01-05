From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [net-next PATCH v2 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Thu, 5 Jan 2017 16:33:48 +0000
Message-ID: <CAJpBn1xsj+bdbZT_br=JEGEKfY2p5vM2EC9Prt6Oi8EApBeeTw@mail.gmail.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
 <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMiSt2a9rQYpjtu=o8YBA2YjPD=6nSwBnh5gfuseQwXCcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        David Miller <davem@davemloft.net>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMiSt2a9rQYpjtu=o8YBA2YjPD=6nSwBnh5gfuseQwXCcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2017 at 12:08 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Jan 3, 2017 at 8:07 PM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>> A host based switching entity like a linux bridge or OVS redirects these frames
>> to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
>> directed transmits to the corresponding VFs. To enable directed transmit, skb
>> metadata dst is used to pass the VF id and the frame is requeued to call the PFs
>> transmit routine.
>
> Jakub/John, patch #4 which didn't appear in the list had a long discussion [1]
> ending  with "lets talk on it @ netdev", did we?

I spoke to a few people, but nobody had much to say about it back then :(

Noob question: can we somehow "debug" why a patch is not appearing on
a vger list?
