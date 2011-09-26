From: "J.Hwan.Kim" <j.hwan.kim99@gmail.com>
Subject: Re: intel 82599 multi-port performance
Date: Tue, 27 Sep 2011 00:42:17 +0900
Message-ID: <4E809D59.10103@gmail.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com>
Reply-To: frog1120@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48192 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab1IZPmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 11:42:25 -0400
Received: by ywb5 with SMTP id 5so4389086ywb.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 08:42:25 -0700 (PDT)
In-Reply-To: <4E808A41.8040902@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011=EB=85=84 09=EC=9B=94 26=EC=9D=BC 23:20, Chris Friesen wrote:
> On 09/26/2011 04:26 AM, J.Hwan Kim wrote:
>> Hi, everyone
>>
>> Now, I'm testing a network card including intel 82599.
>> In our experiment, with the driver modified with ixgbe and multi-por=
t
>> enabled,
>
> What do you mean by "modified with ixgbe and multi-port enabled"? You
> shouldn't need to do anything special to use both ports.
>
>> rx performance of each port with 10Gbps of 64bytes frame is
>> a half than when only 1 port is used.
>
> Sounds like a cpu limitation. What is your cpu usage? How are your
> interrupts routed? Are you using multiple rx queues?
>

Our server is XEON 2.4GHz with 8 cores.
I'm using 4 RSS queues for each port and distributed it's interrupts to=
=20
different cores respectively.
I checked the CPU utilization with TOP, I guess ,it is not cpu imitatio=
n=20
problem.
