From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Fri, 4 Apr 2008 09:27:47 -0700
Message-ID: <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Wenji Wu" <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:58308 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbYDDQ15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 12:27:57 -0400
Received: by yw-out-2324.google.com with SMTP id 5so26008ywb.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2008 09:27:48 -0700 (PDT)
In-Reply-To: <fc471cb97cfd.47f5520e@fnal.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unless you're sending very fast, where the computational overhead of
processing SACK blocks is slowing you down, this is not expected
behavior.  Do you have more detail?  What is the window size, and how
much reordering?

Full binary tcpdumps are very useful in diagnosing this type of problem.

  -John


On Thu, Apr 3, 2008 at 9:54 PM, Wenji Wu <wenji@fnal.gov> wrote:
> Hi, Could any body help me out with Linux TCP SACK? Thanks in advance.
>
>  I run iperf to send traffic from sender to receiver. and add packet reordering in both forward and reverse directions. I found when I turn off the SACK/DSACK option, the throughput is better than with the SACK/DSACK on? How could it happen in this way? did anybody encounter this phenomenon before?
>
>
>  thanks,
>
>  wenji
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
