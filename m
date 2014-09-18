From: Cong Wang <cwang@twopensource.com>
Subject: Re: Calltrace in process_backlog()
Date: Thu, 18 Sep 2014 09:52:03 -0700
Message-ID: <CAHA+R7PR88ObqKm2CnrgU7K8MLN5Q51yYZZOO4uw=Ww5eo9zZA@mail.gmail.com>
References: <alpine.LNX.2.03.1409181138160.5266@127.0.0.1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: sdrb@onet.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:44427 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756296AbaIRQwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 12:52:06 -0400
Received: by mail-la0-f42.google.com with SMTP id hz20so1550474lab.1
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 09:52:03 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1409181138160.5266@127.0.0.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 2:53 AM,  <sdrb@onet.eu> wrote:

> I know that the this problem occures because there is napi->poll_list freed
> twice. But I cannot find out where in my code is the source
> of the problem. How can I find it?
>
> The system bases on single core ARM.
>
> Any suggestions?

Try to enable some VM debug option, for example if you use SLUB enable
CONFIG_SLUB_DEBUG=y, it should be able to catch double free bug.
