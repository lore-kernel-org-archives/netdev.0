From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Fri, 23 Jan 2015 11:33:40 -0800
Message-ID: <CAHA+R7Nk=D6yfNYWjY-72aqc732AKLLS5-XVWRohpFWrQ91FsQ@mail.gmail.com>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:50680 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbbAWTdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 14:33:40 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so8982682iec.11
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 11:33:40 -0800 (PST)
In-Reply-To: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 5:37 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
>
> Known issues: skb_flow_dissect hashes out ipv6 addresses. That needs
> to be changed to store them somewhere so they can be used later on.
>

This has large overlap with cls_flow, I suspect we really
need so many flow dissectors? Or, on the other hand, it might
make sense to move the key computing logic to user-space
so that we don't need to add each of them in kernel?
