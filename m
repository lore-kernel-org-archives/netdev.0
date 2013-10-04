From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Fri, 4 Oct 2013 10:55:49 -0700
Message-ID: <20131004105549.36184810@nehalam.linuxnetplumber.net>
References: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52484 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3JDRzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 13:55:53 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so4324620pdj.32
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 10:55:53 -0700 (PDT)
In-Reply-To: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Oct 2013 13:05:29 +0900
Masatake YAMATO <yamato@redhat.com> wrote:

> ip link has ability to show extra information of net work device if
> kernel provides sunh information. With this patch veth driver can
> provide its peer ifindex information to ip command via netlink
> interface.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---

netlink API's are supposed to be symmetrical.

When creating veth, the VETH_INFO_PEER attribute is struct(ifinfomsg).
The fill_info should tack on the same data.
