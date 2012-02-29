From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 18:12:31 -0800
Message-ID: <CAB=NE6VXyQ-k1Sm3Xf_ABE35+PHSoNqX=AJpLBjNu0sdAdnY4g@mail.gmail.com>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com> <20120228.205347.1718771650331094141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120228.205347.1718771650331094141.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 5:53 PM, David Miller <davem@davemloft.net> wrote:
> From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
> Date: Tue, 28 Feb 2012 17:50:09 -0800
>
>> The next patch adds the new QCA alx Ethernet driver that
>> supercedes the atl1c Ethernet driver. For details please
>> read the commit log of the patch. Given the size you can
>> download the patch from:
>
> What's wrong with making evolutionary fixes to atl1c instead
> of replacing it wholesale?
>
> This isn't the way to do it Luis.

I *vehemently* tried to change direction of this driver development to
do exactly what you stated when this driver was first posted last year
in October of 2011 [0]. I could not get commitment on that route
mainly due to the large delta and lack of resources to address this. I
knew this would still be a hard sale but what I proposed was a
comprise --  consider a replacement *if* we can get QCA engineers
tasked to work upstream and committed to fixing *all* issues reported,
*and* also properly tested and compared drivers.

The other option we had reviewed here was to get this into staging but
the garbage driver code is all resolved now. Its your call. This is
the best I could get commitment and resources on.

[0] http://markmail.org/message/7dk7ltdcdlx5ksu6

  Luis
