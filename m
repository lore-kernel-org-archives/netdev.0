From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2] net: fec: Add "phy-reset-active-low" property to DT
Date: Fri, 12 Feb 2016 13:44:28 -0600
Message-ID: <CAL_JsqJX+MuN3LXW-bSTo1cj2JM0h_dw3JYx6jF7EUZVgDf=gQ@mail.gmail.com>
References: <1455048072-869-1-git-send-email-bernhard@bwalle.de>
 <20160212152011.GA28563@rob-hp-laptop> <CAOMZO5CQmVf7EuOWY+e_+jWjzxXodpTcahJBnzP0x1uapO+okQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bernhard Walle <bernhard@bwalle.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5CQmVf7EuOWY+e_+jWjzxXodpTcahJBnzP0x1uapO+okQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 9:24 AM, Fabio Estevam <festevam@gmail.com> wrote:
> On Fri, Feb 12, 2016 at 1:20 PM, Rob Herring <robh@kernel.org> wrote:
>
>> This is what the gpio flags are for. Why can't you use that?
>
> This has already been discussed in v1:
> https://lkml.org/lkml/2016/2/8/867

Thanks. That's fine, but that detail should be explained in the
binding. Is there a specific compatible string this can be limited to?
It should also be stated that the GPIO flags should be correct rather
than ignored implying I can put in whatever I want there. Then someday
if no more wrong dtbs are in the wild, it can switch back to using
gpio flags. Also, phy-reset-active-low should be prefixed with "fsl,".

Rob
