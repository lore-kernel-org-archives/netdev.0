From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: NVGRE for Linux
Date: Tue, 11 Jun 2013 16:23:25 +0300
Message-ID: <CAEnQRZDvqkSgvS5Ur9L-Q17kNDAVuNn3JsWm5u_raThBD5xubQ@mail.gmail.com>
References: <1902752B0C92F943AB7EA9EE13E2DEEC126A7CC8B8@HQ1-EXCH02.corp.brocade.com>
	<20130610094640.4d3fa0a2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:57343 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab3FKNX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 09:23:26 -0400
Received: by mail-wi0-f177.google.com with SMTP id ey16so4123071wid.16
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 06:23:25 -0700 (PDT)
In-Reply-To: <20130610094640.4d3fa0a2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 7:46 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 10 Jun 2013 08:21:49 -0700
> Daniel Baluta <daniel.baluta@gmail.com> wrote:
>
>> Hi,
>>
>> Is there anyone working on implementing NVGRE [1] in Linux kernel?
>>
>> A significant part of the code can be borrowed from VXLAN [2] (netlink
>> ops, fdb ops),
>> while another important part (packet reception/transmission) is based
>> on GRE tunneling code [3].
>>
>> Is this approach correct? Any suggestions are welcomed.
>>
>> thanks,
>> Daniel.
>>
>> [1] http://datatracker.ietf.org/doc/draft-sridharan-virtualization-nvgre/
>> [2] drivers/net/vxlan.c
>> [3] net/ipv4/ip_gre.c
>
> Packet transmission is not a problem the existing GRE provides more the necessary decode/encode.
> The problem problem is that you would need a management entity. Most of the interesting bits
> for connecting with real world clouds like Azure remain unspecified in RFC.

That's right. The RFC defers a lot of important details for the next
version (e.g 4.4 Address/Policy Management ).
For the moment, I will try to experiment with statically defined fdbs.

Thanks!
