From: Baptiste Covolato <baptiste@arista.com>
Subject: Multiple mac addresses on macvlan
Date: Fri, 27 Mar 2015 13:40:18 -0700
Message-ID: <CABb8VeHFiWDdA2auCpdUD6O+Jtz9S8-KCU9GtXmB-Krx3pobHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34617 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbbC0UkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 16:40:18 -0400
Received: by oigz129 with SMTP id z129so41181031oig.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 13:40:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

We are trying to add multiple mac address to a macvlan. We know that
the usual way to achieve this is to create multiple macvlan devices.
The problem is that creating/deleting many of these is expensive. It
also tends to consume memory. In order to support many VRRP instances
on a single routed port, we would like to have the the ability to add
on the order of 512 MAC addresses.

Has anyone considered associating a list of mac address with a single
macvlan device ?

Thanks,

-- 
Baptiste Covolato
