From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 14:07:23 +0300
Message-ID: <CAJ3xEMg2TUsg0mYCPC=PE1p3BZV1=_CuPsGWH-67frxy+PeUSg@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	<CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	<CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	<CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	<CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
	<CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
	<CAJ3xEMhzxfP3Sqp=_QSQehd2j2s=Gr3B1iO2S--OcoT7VC94nQ@mail.gmail.com>
	<CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
	<CAJ3xEMgPb9BhvtifmTzy6bS9WDf3jUx6dnx4418KNTjGNPreHQ@mail.gmail.com>
	<CA+mtBx-AW65w7grfb7zTaDKzKQ2n_7JQuLquj1Ayopa4gdiF6Q@mail.gmail.com>
	<CAJ3xEMiLsQ=Wd=461L1Wx0jQ+zivY-Z573+90dD8d7pdUD4Skw@mail.gmail.com>
	<CA+mtBx9HMuMnsmN0rjqV9-5iK9H6b+J8OZQsmmbFHwjm+qW7bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:65352 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbaJGLHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 07:07:24 -0400
Received: by mail-oi0-f51.google.com with SMTP id h136so2169609oig.24
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 04:07:23 -0700 (PDT)
In-Reply-To: <CA+mtBx9HMuMnsmN0rjqV9-5iK9H6b+J8OZQsmmbFHwjm+qW7bQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> yes, I will talk about FOU and GUE implementation. You should
> abstracts in the schedule now.

Thanks, I think it would be also good to cover the challenges we're
discussing over this
thread w.r.t nowadays upstream NICs HW/drivers

>> I think a replay of your LKS presentation along with open discussion
>> on how to get there with the legacy requirements could be very
>> helpful.
