From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Wed, 22 Dec 2004 10:36:48 +0100
Message-ID: <41C94030.4050806@trash.net>
References: <20041219203050.GK17998@postel.suug.ch> <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain> <20041220200739.GX17998@postel.suug.ch> <41C7F833.4000909@trash.net> <20041222003142.GB7884@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041222003142.GB7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <41C7F833.4000909@trash.net> 2004-12-21 11:17
> 
>>I'm not sure which areas of the code I can still
>>touch without conflicting with you :)
> 
> 
>  include/linux/pkt_cls.h   |    6 
>  include/linux/rtnetlink.h |    3 
>  include/net/pkt_cls.h     |   45 +++++
>  net/sched/cls_api.c       |  205 +++++++++++++++++++++++++
>  net/sched/cls_fw.c        |  145 +++---------------
>  net/sched/cls_route.c     |  355 ++++++++++++++++++++++++--------------------
>  net/sched/cls_rsvp.h      |   88 +++++------
>  net/sched/cls_tcindex.c   |  364 +++++++++++++++++++++++++---------------------
>  net/sched/cls_u32.c       |  131 ++++------------
>  9 files changed, 766 insertions(+), 576 deletions(-)

Thanks. I'm going to take on the action code then.

Regards
Patrick
