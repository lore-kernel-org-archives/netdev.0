From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 0/7] net: Support checksum in UDP tunnels
Date: Wed, 4 Jun 2014 15:28:40 -0700
Message-ID: <CAEP_g=9=rCQz6fsZ0c4KP7Kd4L8Q2yk8tKON0GVk52Napj5ufA@mail.gmail.com>
References: <alpine.DEB.2.02.1406012046040.20298@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:54350 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751803AbaFDW3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:29:02 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so228699qaq.31
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 15:29:01 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406012046040.20298@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2014 at 9:00 PM, Tom Herbert <therbert@google.com> wrote:
> This patch series adds support for using checksums in UDP tunnels. With
> this it is possible that two or more checksums may be set within the
> same packet and we would like to do that efficiently.

Do you also plan to implement double checksum offload in the absence
of TSO? I know it is functionally correct now but it's not offloaded.
