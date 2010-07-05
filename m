From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Mon, 05 Jul 2010 12:08:17 -0600
Message-ID: <4C321F91.90304@redfish-solutions.com>
References: <4C2F7A55.5090700@redfish-solutions.com> <2md4g7-3s3.ln1@chipmunk.wormnet.eu> <4C2FC2C8.8080203@redfish-solutions.com> <20100703234813.GJ24655@chipmunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:53512 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0GESIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:08:21 -0400
In-Reply-To: <20100703234813.GJ24655@chipmunk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Say, on a slightly different subject... but still having to do with 
setsockopt(IP_TOS)... is it intentional that system call effectively 
does nothing if the socket is in listen(), connect(), or bind() states?

In other words, you have to issue the setsockopt() immediately after the 
socket() call, or it doesn't do anything.

As I remember, that's slightly different semantics from BSD, which 
allows you to change the markings on a bound or listening socket.

I've not walked through the kernel sources to see why this is.

-Philip

