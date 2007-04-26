From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Thu, 26 Apr 2007 22:30:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704262219200.18515@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
 <4630D069.30605@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-347003722-1177615262=:18515"
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53000 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbXDZTa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 15:30:56 -0400
In-Reply-To: <4630D069.30605@redhat.com>
Content-ID: <Pine.LNX.4.64.0704262223440.18515@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-347003722-1177615262=:18515
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0704262223441.18515@kivilampi-30.cs.helsinki.fi>

On Thu, 26 Apr 2007, Chuck Ebbert wrote:

> Ilpo Järvinen wrote:
> > ...I'm unsure how to continue the investigation from this point onward 
> > and asking for ideas/suggestions or how to rule out more possibilities... 
> > Or is there some knob which I don't know of that should be toggled or 
> > something, is 2.6 network stack expected to behave this way?
> > 
> 
> Try a different network adapter.

Hmm, I thought I had already done this but I just noticed that it is so 
that the adapter was still the same as the other host has two adapter (now 
that I look again). I'll give it a try tomorrow to see if using the 
another adapter makes any difference.

> Try turning off hardware TSO offload:
>   ethtool -K ethX tso off

# ethtool -K eth0 tso off
Cannot set device tcp segmentation offload settings: Operation not 
supported

-- 
 i.
---696243703-347003722-1177615262=:18515--
