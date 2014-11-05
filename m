From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can ndo_select_queue save data in skb->cb?
Date: Wed, 05 Nov 2014 10:53:09 -0800
Message-ID: <1415213589.13896.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <545A64EC.309@openvpn.net>
	 <1415211391.13896.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M2k8_9C8=kdAJT1nSFDhKfV2HwvTo0nX-tVDJQvXjy+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: James Yonan <james@openvpn.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:65125 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKESxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:53:11 -0500
Received: by mail-ie0-f174.google.com with SMTP id x19so1328334ier.33
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:53:11 -0800 (PST)
In-Reply-To: <CAHA+R7M2k8_9C8=kdAJT1nSFDhKfV2HwvTo0nX-tVDJQvXjy+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 10:38 -0800, Cong Wang wrote:
> That is only because qdisc layer saves data for bond,
> which means if you have more data to save, you have to put
> more into qdisc CB, it is just ugly.

Right, using skb->cb[] is ugly, dangerous, and all this.

If you can, avoiding it is safer.

Note that I pointed to the bonding case for a legal case,
I had no time to do a full explanation, feel free to do so ;)
