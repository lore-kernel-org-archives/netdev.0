From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Scaling Max IP address limitation
Date: Sun, 24 Jun 2007 21:59:39 +0200
Message-ID: <7e63f56c0706241259u6e123ed6yc02b76f0260adaa5@mail.gmail.com>
References: <467EA7C1.4080006@rossove.com>
	 <20070624110236.fa36b2f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: djones@rossove.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:43880 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbXFXT7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 15:59:39 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1273087wxc
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 12:59:39 -0700 (PDT)
In-Reply-To: <20070624110236.fa36b2f9.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> On Sun, 24 Jun 2007 12:20:01 -0500 David Jones <djones@rossove.com> wrote:

> > I am trying to add multiple IP addresses ( v6 ) to my FC7 box on eth0.
> > But I am hitting a max limit of 4000 IP address . Seems like there is a
> > limiting variable in linux kernel (which one? ) that prevents from
> > adding more IP addresses than 4096. What do I need to change in Linux
> > kernel  ( and then recompile ) to be able to add more IP addresses than
> > 4K addresses per system? ..


We are adding tens of thousand IPv4 addresses using netlink interface
without any problems. The maximum we added was 60K of secondary
IPv4 addresses. It consumes some memory, however.

We have also added thousands of IPv6. I will try to test, if there is any
limit for doing it.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
