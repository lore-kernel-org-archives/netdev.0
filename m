From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3.16]r9169:  Correct Set Vlan tag
Date: Tue, 29 Mar 2016 06:29:04 -0700
Message-ID: <1459258144.6473.170.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459240400-1602-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35134 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcC2N3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:29:07 -0400
Received: by mail-pf0-f175.google.com with SMTP id n5so14404870pfn.2
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:29:06 -0700 (PDT)
In-Reply-To: <1459240400-1602-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-29 at 11:33 +0300, Corcodel Marian wrote:
>  This patch add set Vlan tag and flush CPlusCmd register because when unset
>  RxVlan and RxChkSum bit, whithout some explication , unwanted bits
>  is set, PCIDAC, PCIMulRW  and others.Whithout this patch when run
>  ethtool -d eth0 on "C+ Command" field missing "VLAN de-tagging"

Are you a bot or a human being ?

It really looks like a program was assigned to fool us, sending
random patches targeting r8169 and random linux kernels.

We wont accept patches if they are not targeting current linux kernels.
