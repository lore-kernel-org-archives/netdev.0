From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: htb parallelism on multi-core platforms
Date: Sat, 18 Apr 2009 03:21:50 +0300
Message-ID: <200904180321.50281.denys@visp.net.lb>
References: <1239964844.21569.57.camel@blade.ines.ro> <49E905A2.7040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38347 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbZDRATK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 20:19:10 -0400
In-Reply-To: <49E905A2.7040402@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 18 April 2009 01:41:38 Jarek Poplawski wrote:
> Radu Rendec wrote, On 04/17/2009 12:40 PM:
> > Hi,
>
> Hi Radu,

> I don't know about anything (simple) for this, but I wonder if you
> tried already any htb tweaking like htb_hysteresis module param or
> burst/cburst class parameters to limit some maybe useless resolution/
> overhead?
Like adding HZ=1000 as environment variable in scripts :-)
For me it helps....
Also worth to try HFSC.
