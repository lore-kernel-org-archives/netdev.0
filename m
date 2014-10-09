From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: [PATCH] ipv6: honour non local bind
Date: Thu, 9 Oct 2014 19:07:52 +0200
Message-ID: <DUB123-W108DA950E52906D29ADEC4EDA00@phx.gbl>
References: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "michele.dionisio@gmail.com" <michele.dionisio@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc4s7.hotmail.com ([157.55.2.82]:50400 "EHLO
	DUB004-OMC4S7.hotmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaJIRM4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 13:12:56 -0400
In-Reply-To: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michele,


> I see that net.ipv4.ip_nonlocal_bind = 1 does not works on ipv6 if
> you try to bind on not local ip.
> An easy test to see the issue using python is:
>
> set net.ipv4.ip_nonlocal_bind = 1 and in python shell try to execute
>
> import socket
> s = socket.socket(family=socket.AF_INET6)
> s.bind(('2a01:84a0:1001:A001:0000:0:0015:8', 1234))
>
> you receive an error. In ipv4 it works.
>
> The patch attached solve the issue


This has been proposed in the past and refused:
http://marc.info/?t=132369669000005&r=1&w=2

You will have to set the available socket options from the application.



Regards,

Lukas


 		 	   		  