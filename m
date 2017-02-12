From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Sun, 12 Feb 2017 18:31:52 +0200
Message-ID: <2a345874-2ad7-997e-2904-0d56148a2c56@gmail.com>
References: <20170209135838.16487-1-edumazet@google.com>
 <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
 <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com>
 <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
 <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35019 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751265AbdBLQb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 11:31:56 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so20740431wra.2
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 08:31:55 -0800 (PST)
In-Reply-To: <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/02/2017 6:56 PM, Eric Dumazet wrote:
>> Default, out of box.
> Well. Please report :
>
> ethtool  -l eth0
> ethtool -g eth0
$ ethtool -g p1p1
Ring parameters for p1p1:
Pre-set maximums:
RX:             8192
RX Mini:        0
RX Jumbo:       0
TX:             8192
Current hardware settings:
RX:             1024
RX Mini:        0
RX Jumbo:       0
TX:             512

$ ethtool -l p1p1
Channel parameters for p1p1:
Pre-set maximums:
RX:             128
TX:             32
Other:          0
Combined:       0
Current hardware settings:
RX:             8
TX:             32
Other:          0
Combined:       0
