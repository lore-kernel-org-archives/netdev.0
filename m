From: Andrei Warkentin <andreiw@motorola.com>
Subject: Re: [PATCHv4] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.
Date: Tue, 9 Aug 2011 00:12:45 -0500
Message-ID: <CALfQTu7x5NVjLCEWenXR8nK1fVZ1c6190FA8+84Teksrm_Wg8w@mail.gmail.com>
References: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
	<1312578250-2944-2-git-send-email-andreiw@motorola.com>
	<20110808131230.7f4b4d99@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:34317 "EHLO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1HIFMs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 01:12:48 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.22.94.168])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p795DWSa020725
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 01:13:32 -0400 (EDT)
Received: from mail-ww0-f46.google.com (mail-ww0-f46.google.com [74.125.82.46])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p795BA6g020274
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 01:13:31 -0400 (EDT)
Received: by mail-ww0-f46.google.com with SMTP id 27so2841049wwf.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 22:12:45 -0700 (PDT)
In-Reply-To: <20110808131230.7f4b4d99@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 8, 2011 at 3:12 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Fri, =A05 Aug 2011 16:04:10 -0500
> Andrei Warkentin <andreiw@motorola.com> wrote:
>
>> This ensures the neighbor entries associated with the bridge
>> dev are flushed, also invalidating the associated cached L2 headers.
>>
>> This means we br_add_if/br_del_if ports to implement hand-over and
>> not wind up with bridge packets going out with stale MAC.
>>
>> This means we can also change MAC of port device and also not wind
>> up with bridge packets going out with stale MAC.
>>
>> This builds on Stephen Hemminger's patch, also handling the br_del_i=
f
>> case and the port MAC change case.
>>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Andrei Warkentin <andreiw@motorola.com>
>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>

Thank you for the Ack.

A
