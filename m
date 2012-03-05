From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Mon, 05 Mar 2012 07:21:45 -0600
Message-ID: <4F54BDE9.5080505@codemonkey.ws>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>	 <1329519726-25763-2-git-send-email-aliguori@us.ibm.com>	 <20120219144145.GA16620@redhat.com>	 <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>	 <20120220192708.GA18308@redhat.com> <4F42A2FB.7000501@us.ibm.com>	 <20120220210005.GA19278@redhat.com>	 <1329786250.13141.9.camel@localhost.localdomain>	 <20120221032147.GB2502@redhat.com> <1329796998.13141.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <aliguori@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53452 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165Ab2CENVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 08:21:50 -0500
Received: by pbcun15 with SMTP id un15so2777156pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 05:21:50 -0800 (PST)
In-Reply-To: <1329796998.13141.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2012 10:03 PM, Shirley Ma wrote:
> On Tue, 2012-02-21 at 05:21 +0200, Michael S. Tsirkin wrote:
>> On Mon, Feb 20, 2012 at 05:04:10PM -0800, Shirley Ma wrote:
>>> On Mon, 2012-02-20 at 23:00 +0200, Michael S. Tsirkin wrote:
>>>>
>>>> The point was really to avoid scheduler overhead
>>>> as with tcp, tx and rx tend to run on the same cpu.
>>>
>>> We have tried different approaches in the past, like splitting vhost
>>> thread to separate TX, RX threads; create per cpu vhost thread
>> instead
>>> of creating per VM per virtio_net vhost thread...
>>>
>>> We think per cpu vhost thread is a better approach based on the data
>> we
>>> have collected. It will reduce both vhost resource and scheduler
>>> overhead. It will not depend on host scheduler, has less various.
>> The
>>> patch is under testing, we hope we can post it soon.
>>>
>>> Thanks
>>> Shirley
>>
>> Yes, great, this is definitely interesting. I actually started with
>> a per-cpu one - it did not perform well but I did not
>> figure out why, switching to a single thread fixed it
>> and I did not dig into it.
>
> The patch includes per cpu vhost thread&  vhost NUMA aware scheduling

Hi Shirley,

Are you planning on posting these patches soon?

Regards,

Anthony Liguori
