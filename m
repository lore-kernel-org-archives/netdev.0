From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: add missing dst port setup option
Date: Fri, 10 Jan 2014 15:36:54 -0800
Message-ID: <20140110153654.2548f143@nehalam.linuxnetplumber.net>
References: <1389268586-3205-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:64814 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaAJXg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:36:56 -0500
Received: by mail-pd0-f171.google.com with SMTP id x10so481453pdj.16
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 15:36:56 -0800 (PST)
In-Reply-To: <1389268586-3205-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Jan 2014 12:56:26 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> Kernel commit 823aa873bc ("vxlan: allow choosing destination port
> per vxlan") and 553675fb5e ("vxlan: listen on multiple ports")
> make it "now possible to define the same virtual network id but
> with different UDP port values which can be useful for migration."
> 
> However, IFLA_VXLAN_PORT netlink attribute was available in the
> kernel but hasn't been pushed to iproute2 in order to make use
> of it, hence, add this option so that people can use it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  ip/iplink_vxlan.c     | 17 ++++++++++++++++-
>  man/man8/ip-link.8.in |  6 ++++++
>  2 files changed, 22 insertions(+), 1 deletion(-)
> 

I restored the older version of IFLA_VXLAN_PORT stuff that was reverted
because that option was broken on 3.10.
