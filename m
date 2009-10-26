From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Increasing TCP initial cwnd
Date: Mon, 26 Oct 2009 15:54:13 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0910261553180.19761@wel-95.cs.helsinki.fi>
References: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Yair Gottdenker <yairgott@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbZJZNyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 09:54:10 -0400
In-Reply-To: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2009, Yair Gottdenker wrote:

> I am working on research project to control the sender initial
> congestion window size. I am trying to allow user space to set the
> initial congestion window size but with no luck. The sender always
> sends just 4 packets disregarding from the snd_cwnd.
> 
> I am working on kernel version 2.6.31.3.
> 
> I made the following changes:
> 1. tcp_ipv4.c -> in function tcp_v4_init_sock, changed from
> tp->snd_cwnd = 2 to tp->snd_cwnd = user_space_initial_cwnd.
> 2. tcp_output.c -> tcp_init_cwnd - to always return user_space_initial_cwnd.
> 3. tcp_cong.c -> tcp_slow_start- to always return user_space_initial_cwnd.
> 
> Any help will be more than welcome.

How about trying tcp_init_metrics in tcp_input.c?

-- 
 i.
