From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Increasing TCP initial cwnd
Date: Mon, 26 Oct 2009 15:57:44 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0910261555450.19761@wel-95.cs.helsinki.fi>
References: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com> <alpine.DEB.2.00.0910261553180.19761@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1417950103-1256565464=:19761"
Cc: Netdev <netdev@vger.kernel.org>
To: Yair Gottdenker <yairgott@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42315 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbZJZN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 09:57:40 -0400
In-Reply-To: <alpine.DEB.2.00.0910261553180.19761@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1417950103-1256565464=:19761
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Mon, 26 Oct 2009, Ilpo Järvinen wrote:

> On Mon, 26 Oct 2009, Yair Gottdenker wrote:
> 
> > I am working on research project to control the sender initial
> > congestion window size. I am trying to allow user space to set the
> > initial congestion window size but with no luck. The sender always
> > sends just 4 packets disregarding from the snd_cwnd.
> > 
> > I am working on kernel version 2.6.31.3.
> > 
> > I made the following changes:
> > 1. tcp_ipv4.c -> in function tcp_v4_init_sock, changed from
> > tp->snd_cwnd = 2 to tp->snd_cwnd = user_space_initial_cwnd.
> > 2. tcp_output.c -> tcp_init_cwnd - to always return user_space_initial_cwnd.
> > 3. tcp_cong.c -> tcp_slow_start- to always return user_space_initial_cwnd.
> > 
> > Any help will be more than welcome.
> 
> How about trying tcp_init_metrics in tcp_input.c?

Also, now that I looked. I don't understand what interesting you find in 
tcp_slow_start to modify? That certainly has nothing to do with initial 
window. ....Then you also might want to play with RW but that 
is out-of-scope of your question, just mentioning it for completeleness.

-- 
 i.
--8323329-1417950103-1256565464=:19761--
