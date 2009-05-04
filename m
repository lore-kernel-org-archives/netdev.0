From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 22:43:34 +0200
Message-ID: <49FF5376.805@gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com> <49FF325B.4050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:35460 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365AbZEDUof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 16:44:35 -0400
Received: by bwz22 with SMTP id 22so731322bwz.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 13:44:34 -0700 (PDT)
In-Reply-To: <49FF325B.4050802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 05/04/2009 08:22 PM:

> Tom Herbert wrote, On 05/04/2009 06:03 AM:
> 
>> This is an update of the receive packet steering patch (RPS) based on received
>> comments (thanks for all the comments).  Improvements are:
> 
> ...
> 
>> +/* Called from hardirq (IPI) context */
>> +static void trigger_softirq(void *data)
>> +{
>> +	struct softnet_data *queue = data;
>> +	__napi_schedule(&queue->backlog);
>> +}
> 
> 
> Isn't full napi_schedule() needed here?
 

Hmm... It seems to be OK yet.

Jarek P.


