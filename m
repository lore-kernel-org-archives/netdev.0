From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Beyond 64K TCP connections limit per IP-address
Date: Wed, 4 Jul 2007 11:40:48 +0200
Message-ID: <7e63f56c0707040240p4ec962fajd93074909b07ea03@mail.gmail.com>
References: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
	 <20070704093658.GD15210@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:38556 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019AbXGDJks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 05:40:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2034144wxd
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 02:40:48 -0700 (PDT)
In-Reply-To: <20070704093658.GD15210@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/4/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Wed, Jul 04, 2007 at 09:50:31AM +0200, Robert Iakobashvili (coroberti@gmail.com) wrote:
> > If I am correct, a TCP server can make up to
> > 64K accepts for a port at a single IP-address.
>
> No, it is essentially unlimited - linux uses local/remote addr/port
> tuples for hash chains, so there is no per-addr limits.
> If there is some kind of binds, then yes, only 64k ports per address.

Thanks, it clarified me the issue.
Probably, I am experiencing some local problem with
the web-server I am using for tests.


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
