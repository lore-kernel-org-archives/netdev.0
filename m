From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP MD5 connections get stuck with IPV6 mapped listener
Date: Wed, 15 Jul 2009 13:42:58 -0700
Message-ID: <20090715134258.0c523ff4@s6510>
References: <20090715121119.12fc69e5@s6510>
	<1247686985.7129.15.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027AbZGOUm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 16:42:59 -0400
In-Reply-To: <1247686985.7129.15.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jul 2009 14:43:05 -0500
John Dykstra <john.dykstra1@gmail.com> wrote:

> On Wed, 2009-07-15 at 12:11 -0700, Stephen Hemminger wrote:
> > While investigating some TCP MD5 issues, with BGP, broke things
> > up into a simple test program found that
> > if server is listening on IPV6 for TCP with MD5 key
> > and client connects with IPV4 MD5 key, the connection gets stuck after
> > the initial SYN-SENT, SYN-ACK.
> 
> Just cause I've been burned recently....
> 
> Which kernel did you reproduce this on, and have you tried 2.6.31-rcx?

yes 2.6.31-rc3
