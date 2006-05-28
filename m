From: "Thomas Kho" <thomaskho@gmail.com>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Sun, 28 May 2006 15:22:26 -0700
Message-ID: <ad4ecd9f0605281522n20948429ye4d5abfd6a1288aa@mail.gmail.com>
References: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:13622 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751018AbWE1WW1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 18:22:27 -0400
Received: by ug-out-1314.google.com with SMTP id a2so91330ugf
        for <netdev@vger.kernel.org>; Sun, 28 May 2006 15:22:26 -0700 (PDT)
To: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
In-Reply-To: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/24/06, #ZHOU BIN# <ZHOU0022@ntu.edu.sg> wrote:
> +       u16     cntRTT;         /* # of RTTs measured within last RTT */

> +       /* veno->cntRTT = 0; */

It looks like this counter is never initialized, and the comment is deceiving.

Thomas Kho
