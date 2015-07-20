From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] net: vnet: relocate netlink code section comment
Date: Mon, 20 Jul 2015 20:12:52 +0300
Message-ID: <20150720171252.GP13027@tarshish>
References: <7f4c030ea15ee6217af4809c834a7cbebcd66709.1437291650.git.baruch@tkos.co.il>
 <CAHA+R7P63k8Fy+2fcXDdj1fKhYs+CUq=AihnoF7weM3ROnLnHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:34885 "EHLO
	mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756136AbbGTRM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 13:12:57 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7P63k8Fy+2fcXDdj1fKhYs+CUq=AihnoF7weM3ROnLnHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong Wang,

On Mon, Jul 20, 2015 at 10:07:00AM -0700, Cong Wang wrote:
> On Sun, Jul 19, 2015 at 12:40 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> > The veth_setup() routine and the VETH_FEATURES macro are also part of the
> > netlink interface (referenced from struct rtnl_link_ops). Include them under
> > the netlink code section comment.
> 
> Or just remove it? I don't think comment like this one is useful.

The veth.c file contain a few more separator comments. Would you suggest to 
remove them all?

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
