From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 0/3] CAN Filter/Classifier
Date: Mon, 4 Jun 2012 12:13:42 -0700
Message-ID: <20120604121342.53c57050@nehalam.linuxnetplumber.net>
References: <1338826149-11604-1-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338826149-11604-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  4 Jun 2012 18:09:06 +0200
Rostislav Lisovy <lisovy@gmail.com> wrote:

> This classifier classifies CAN frames (AF_CAN) according to their
> identifiers. This functionality can not be easily achieved with
> existing classifiers, such as u32. This classifier can be used
> with any available qdisc and it is able to classify both SFF
> or EFF frames.
> 
> The filtering rules for EFF frames are stored in an array, which
> is traversed during classification. A bitmap is used to store SFF
> rules -- one bit for each ID.
> 
> More info about the project:
> http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf
> 
> 
> Rostislav Lisovy (3):
>   Add missing can.h
>   CAN Filter/Classifier -- Source code
>   CAN Filter/Classifier -- Documentation
> 
>  include/linux/can.h     |  112 ++++++++++++++++++++++
>  include/linux/pkt_cls.h |   10 ++
>  man/man8/tc-can.8       |   97 +++++++++++++++++++
>  tc/Makefile             |    1 +
>  tc/f_can.c              |  238 +++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 458 insertions(+)
>  create mode 100644 include/linux/can.h
>  create mode 100644 man/man8/tc-can.8
>  create mode 100644 tc/f_can.c

Please resubmit these when the necessary upstream pieces are in Linus's tree.
That will be during the 3.6 merge window.
