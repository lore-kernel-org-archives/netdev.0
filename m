From: Joe Perches <joe@perches.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 08:40:08 -0700
Message-ID: <1471966808.3746.109.camel@perches.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
         <1471961184.3746.92.camel@perches.com>
         <CAOp4FwRxfE61azV78TZ7EKESQZzRU2Pfkc2GJ9j3MV7pr80qew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Luis Henriques <luis.henriques@canonical.com>,
        Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOp4FwRxfE61azV78TZ7EKESQZzRU2Pfkc2GJ9j3MV7pr80qew@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 19:27 +0400, Loganaden Velvindron wrote:
> Better be safe than sorry.

Better still would be to create a tool via something like
coccinelle that could be run on the entire kernel than
submit a single patch for a construct that likely occurs
dozens of times in the kernel source tree.

(and please do not send html formatted emails to lkml)
