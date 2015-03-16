From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on stacked
 netdevices
Date: Mon, 16 Mar 2015 08:09:59 -0700
Message-ID: <5506F247.2020701@cumulusnetworks.com>
References: <CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com> <20150315191722.GE3518@nanopsycho.orion> <CAE4R7bDaBQF8kD1Qi9EJ0pApfCEQeQ1z3DQuZjJXZw55NbmyMg@mail.gmail.com> <20150315.183312.401696632034773662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35085 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933495AbbCPPKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:10:02 -0400
Received: by pabyw6 with SMTP id yw6so67454429pab.2
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 08:10:01 -0700 (PDT)
In-Reply-To: <20150315.183312.401696632034773662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/15, 3:33 PM, David Miller wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Sun, 15 Mar 2015 13:03:06 -0700
>
>> I'm proposing a simple, permissive solution, with a provision for an
>> out on a case-by-case basis.  Right now I don't see any reason to
>> special case any middle driver; just let STP state propagate down to
>> the port device.
> +1
ok. That was the path i had taken initially (see for getlink/setlink):
http://www.spinics.net/lists/netdev/msg313436.html

I have resubmitted the patch with rollback to transparently following 
lowerdevs.
My version also does not follow lowerdevs if NETIF_F_HW_SWITCH_OFFLOAD 
is not
set. And this is set on bonds and teams if any one of their lowerdevs 
have it currently.

thanks.
