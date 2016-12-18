From: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
Subject: Re: regression: ath_tx_edma_tasklet() Illegal idle entry in RCU
 read-side critical section
Date: Sun, 18 Dec 2016 21:04:07 +0100
Message-ID: <aa88f071-edb7-7690-e0e5-b3e2c93e6539@mni.thm.de>
References: <23a2a3ab-974a-ed26-6afa-aafab9bb972e@gmail.com>
 <20161218155938.GP3924@linux.vnet.ibm.com>
 <58b67d5b-0275-f80f-479f-78cf748b4319@mni.thm.de>
 <87pokpc8ng.fsf@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
        Gabriel C <nix.or.die@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        ath9k-devel <ath9k-devel@qca.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nbd@nbd.name" <nbd@nbd.name>
To: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout1.fh-giessen.de ([212.201.18.42]:48666 "EHLO
        mout1.fh-giessen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752112AbcLRUEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 15:04:11 -0500
Received: from mx1.fh-giessen.de ([212.201.18.40])
        by mout1.fh-giessen.de with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.84_2)
        (envelope-from <tobias.johannes.klausmann@mni.thm.de>)
        id 1cIhgm-000FTw-Uj
        for netdev@vger.kernel.org; Sun, 18 Dec 2016 21:04:08 +0100
Received: from mailgate-2.its.fh-giessen.de ([212.201.18.14])
        by mx1.fh-giessen.de with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.84_2)
        (envelope-from <tobias.johannes.klausmann@mni.thm.de>)
        id 1cIhgm-0002Bt-S0
        for netdev@vger.kernel.org; Sun, 18 Dec 2016 21:04:08 +0100
In-Reply-To: <87pokpc8ng.fsf@qca.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18.12.2016 20:57, Valo, Kalle wrote:
> Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de> writes:
>
>> A patch for this is already floating on the ML for a while now latest:
>> (ath9k: do not return early to fix rcu unlocking)
> It's here:
>
> https://patchwork.kernel.org/patch/9472709/

Good to know!
>
>> Hopefully Kalle will include it in one of his upcoming pull requests.
> Yes, I'll try to get it to 4.10-rc2.

Thanks for the update!
