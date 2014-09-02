From: Cong Wang <cwang@twopensource.com>
Subject: Re: Order of interfaces in output of ip link
Date: Tue, 2 Sep 2014 12:30:02 -0700
Message-ID: <CAHA+R7Ps+Fz7tww0-4XOtYT4-=iPYhA7OQxLTJcJYFptiRzsnA@mail.gmail.com>
References: <19313218.dxlnVqzEMb@hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Ovidiu Mara <ovidiu.mara@epfl.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:60437 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbaIBTaE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 15:30:04 -0400
Received: by mail-la0-f52.google.com with SMTP id ty20so8540398lab.11
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 12:30:02 -0700 (PDT)
In-Reply-To: <19313218.dxlnVqzEMb@hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 7:27 AM, Ovidiu Mara <ovidiu.mara@epfl.ch> wrote:
> eth0 and eth1 are two ports on the same network card, so I would expect them to be shown together, as they are numbered. According to the documentation I found here ( http://www.policyrouting.org/iproute2.doc.html#ss9.1.1 ): "The number followed by a colon is the interface index or ifindex. This number uniquely identifies the interface. If you look at the output from cat /proc/net/dev you will see that the network devices are listed in the same order as the numbering you see here."
>

You can't rely on the output order to tell if they are the ports
on the same card, you need to dig some other information
for example sysfs.
