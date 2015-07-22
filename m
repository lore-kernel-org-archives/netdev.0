From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [RFC PATCH v2 net-next 3/3] tcp: add NV congestion control
Date: Wed, 22 Jul 2015 07:27:00 -0400
Message-ID: <CADVnQym6x7Mue-T4xnDRfa4QSStdJ1CQ1bzfNZs+o=tQb+G0+A@mail.gmail.com>
References: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
	<1437538896-1330704-4-git-send-email-brakmo@fb.com>
	<CAK6E8=cmjY1HNhwx3rnXq3h3Gz2c5Mj7x_7LVg97bLwJ0EqeCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36146 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934001AbbGVL1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 07:27:02 -0400
Received: by obnw1 with SMTP id w1so132025401obn.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 04:27:01 -0700 (PDT)
In-Reply-To: <CAK6E8=cmjY1HNhwx3rnXq3h3Gz2c5Mj7x_7LVg97bLwJ0EqeCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 2:50 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Jul 21, 2015 at 9:21 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>> This is a request for comments.
>>
>> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier version of
>> NV was presented at 2010's LPC (slides). It is a delayed based
>> congestion avoidance for the data center. This version has been tested
>> within a 10G rack where the HW RTTs are 20-50us.
>>
>> A description of TCP-NV, including implementation and experimental
>> results, can be found at:
>> http://www.brakmo.org/networking/tcp-nv/TCPNV.html
>>
>> The current version includes many module parameters to support
>> experimentation with the parameters.
...
>> +extern int sysctl_tcp_nv_enable;

The sysctl_tcp_nv_enable only seems to be used within the NV module.
Can it be a module parameter instead of sysctl?

neal
