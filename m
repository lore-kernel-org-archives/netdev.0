From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 08 Sep 2016 08:15:25 -0700
Message-ID: <87d1ketoc2.fsf@tassilo.jf.intel.com>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4265 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965283AbcIHPP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 11:15:28 -0400
In-Reply-To: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
        (D. Herrendoerfer's message of "Thu, 8 Sep 2016 15:06:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> writes:
>
> I may be missing something here - I'm pretty sure there I am, but is
> there any conceptual
>
> reason why this should not be done this way ?

What happens if someone floods the network with random mac addresses?
Sounds like an easy way to do a DoS attack against your host?

-Andi
