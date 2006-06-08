From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Using netconsole for debugging suspend/resume
Date: Thu, 08 Jun 2006 10:50:57 -0700
Message-ID: <44886381.9050506@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:33696 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S964934AbWFHT3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 15:29:13 -0400
To: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been trying to get suspend/resume working well on my new laptop.  
In general, netconsole has been pretty useful for extracting oopses and 
other messages, but it is of more limited help in debugging the actual 
suspend/resume cycle.  The problem looks like the e1000 driver won't 
suspend while netconsole is using it, so I have to rmmod/modprobe 
netconsole around the actual suspend/resume.

This is a big problem during resume because the screen is also blank, so 
I get no useful clue as to what went wrong when things go wrong.  I'm 
wondering if there's some way to keep netconsole alive to the last 
possible moment during suspend, and re-woken as soon as possible during 
resume.  It would be nice to have a clean solution, but I'm willing to 
use a bletcherous hack if that's what it takes.

Any ideas?

Thanks,
    J

