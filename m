From: sainath grandhi <saiallforums@gmail.com>
Subject: Re: packet tracing
Date: Wed, 6 May 2015 23:52:57 -0700
Message-ID: <CABqzqi486+ET65Eyyy4R26ic_S_mi+w6nd70gfzsMwdt7nLiLA@mail.gmail.com>
References: <CABqzqi5f7JMY7MLXxeUn1_vdO9j0uL3-_eZ8fdp349rX1Kz7cg@mail.gmail.com>
	<20150507062655.GB21015@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33239 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbbEGGw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 02:52:57 -0400
Received: by qgdy78 with SMTP id y78so16541325qgd.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 23:52:57 -0700 (PDT)
In-Reply-To: <20150507062655.GB21015@haze>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Erik,
   Are you referring to something like this?

iptables -A LOGGING -j LOG

On Wed, May 6, 2015 at 11:26 PM, Erik Hugne <erik.hugne@ericsson.com> wrote:
> On Wed, May 06, 2015 at 11:16:32PM -0700, sainath grandhi wrote:
>> Hello,
>>     Is there any debug message framework in place for tracking a
>> network packet as it passes through different kernel stack layers
>> (layer 3, layer 2, bridge devices, drivers etc)?
>
> Try iptables LOG target
