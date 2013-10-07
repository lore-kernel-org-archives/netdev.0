From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: dev: fix nlmsg size calculation in  =?UTF-8?Q?can=5Fget=5Fsize=28=29?=
Date: Mon, 07 Oct 2013 16:24:28 +0200
Message-ID: <705c23ba0332d9658b8760cd5d460e8a@grandegger.com>
References: <1381001117-19624-1-git-send-email-mkl@pengutronix.de>
 <52507B7D.6030008@grandegger.com> <5252C1CC.4060809@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<kernel@pengutronix.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5252C1CC.4060809@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 07 Oct 2013 16:14:36 +0200, Marc Kleine-Budde <mkl@pengutronix.de>

wrote:

> On 10/05/2013 10:50 PM, Wolfgang Grandegger wrote:

>> On 10/05/2013 09:25 PM, Marc Kleine-Budde wrote:

>>> This patch fixes the calculation of the nlmsg size, by adding the

>>> missing

>>> nla_total_size().

>>>

>>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

>>> ---

>>> Hello,

>>>

>>> this patch touches the rtnl_link_ops get_size() callback:

>>>

>>>     static struct rtnl_link_ops can_link_ops __read_mostly = {

>>>     ...

>>>     	.get_size	= can_get_size,

>>>     ...

>>>     };

>>>

>>> By looking at other nlmsg size calculation I think a nla_total_size()

>>> for all

>>> contributers is needed. Am I correct?

>> 

>> Yes, seems so, nla_put() calls this code:

>> 

>>   http://lxr.free-electrons.com/source/lib/nlattr.c#L328

> 

> Is this an Acked-by? :)



Yep, obviously a long time ago that I did something for Linux-CAN :(.



Wolfgang.



> 

> Marc
