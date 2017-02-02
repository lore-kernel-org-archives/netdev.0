From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Thu, 02 Feb 2017 04:31:33 -0800
Message-ID: <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
         <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34532 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdBBMbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 07:31:35 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so1741979pgj.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 04:31:35 -0800 (PST)
In-Reply-To: <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 11:37 +0100, Simon Horman wrote:
> Allow dissection of Neighbour Discovery target IP, and source and
> destination link-layer addresses for neighbour solicitation and
> advertisement messages.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---

Hi Simon

Why is this needed ?

Any code added in flow dissector needs to be extra careful,
we had various packet of deaths errors recently in this area.

Thanks.
