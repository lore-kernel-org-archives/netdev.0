From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: ethtool.h compile warning on c++
Date: Mon, 17 Oct 2016 15:56:52 +0200
Message-ID: <97e042b4-3d38-c835-fa5d-9fa92c04edb6@redhat.com>
References: <2f8c5516-210e-83a4-669f-9bd9316a845f@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932180AbcJQN4y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 09:56:54 -0400
In-Reply-To: <2f8c5516-210e-83a4-669f-9bd9316a845f@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 14.10.2016 v 21:46 Ben Greear napsal(a):
> I am getting warnings about sign missmatch.
>
> Maybe make SPEED_UNKNOWN be ((__u32)(0xFFFFFFFF)) ?
>
The 0xFFFFFFFFU could be better.

Ivan
