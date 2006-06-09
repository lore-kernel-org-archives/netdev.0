From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Thu, 08 Jun 2006 18:56:53 -0700
Message-ID: <4488D565.2020103@goop.org>
References: <44886381.9050506@goop.org> <200606082240.31473.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:8065 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S965139AbWFIEEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 00:04:22 -0400
To: "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <200606082240.31473.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> Please try doing "echo 8 > /proc/sys/kernel/printk" before suspend.
>   
Um, why?  That would increase the amount of log output, but I don't see 
how it would help with netconsole preventing suspend, or not being able 
to see console messages on a blank screen after resume.

    J

