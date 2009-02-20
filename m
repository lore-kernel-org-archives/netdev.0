From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 20 Feb 2009 18:12:47 +0200
Message-ID: <200902201812.47205.denys@visp.net.lb>
References: <200902192304.35547.denys@visp.net.lb> <200902201349.47984.denys@visp.net.lb> <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:55781 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbZBTQQN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 11:16:13 -0500
In-Reply-To: <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 February 2009 18:09:54 Ilpo J=E4rvinen wrote:
> > [45853.641072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrun=
k
> > window 1905466446:1905480750 (repaired)
>
> Hmm, we might have sent past our allowed window due to some bug. ...O=
r
> combined some segments in the new shifting code incorrectly past the
> right edge of the window though I quickly checked and we do check for
> tcp_send_head there so it should be right.


This message (about window), i have tons of them, and had before a lot.=
=20

I think it is not related, just i paste whole dmesg part where i see=20
more "Leak" messages. I'm sure i have more of them now.
