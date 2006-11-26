From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Sun, 26 Nov 2006 00:27:33 -0500
Message-ID: <200611260027.33773.dtor@insightbb.com>
References: <200610031457.33215.chunkeey@web.de> <200611250039.03597.dtor@insightbb.com> <200611251750.37313.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:59779 "EHLO
	asav10.insightbb.com") by vger.kernel.org with ESMTP
	id S935241AbWKZF1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 00:27:35 -0500
To: chunkeey@web.de
In-Reply-To: <200611251750.37313.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 25 November 2006 11:50, chunkeey@web.de wrote:
> On Saturday, 25. November 2006 06:39, you wrote:
> > Ok, it looks like the patch changed the order of netdevice registration vs.
> > requesting firmware. My scripts are trying to set ESSID and keys before
> > firmware even gets loaded into the card. You may want to make sure that
> > newer distributions immune to such change before pushing the patch to
> > mainline.
> 
> Ok, I think I know what was "wrong", this new patch should fix the problem.
> Can you try it? 
>

Sorry, still need the second "ifup" to bring the card up after plugging
it in. ping -f looks good however, I will try to stress it more and will
report if I see anything wrong.

-- 
Dmitry
