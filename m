From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 30 Apr 2010 19:58:41 +0200
Message-ID: <4BDB1A51.20505@grandegger.com>
References: <20100429091936.GA6703@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:58082 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758972Ab0D3SAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:00:39 -0400
In-Reply-To: <20100429091936.GA6703@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> exposed to user space as a character device with ioctls that allow tuning
> of the PTP clock.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  Documentation/ptp/ptp.txt        |   78 ++++++++++
>  Documentation/ptp/testptp.c      |  130 ++++++++++++++++
>  Documentation/ptp/testptp.mk     |   33 ++++
>  drivers/Kconfig                  |    2 +
>  drivers/Makefile                 |    1 +
>  drivers/ptp/Kconfig              |   26 ++++
>  drivers/ptp/Makefile             |    5 +
>  drivers/ptp/ptp_clock.c          |  302 ++++++++++++++++++++++++++++++++++++++
>  include/linux/Kbuild             |    1 +
>  include/linux/ptp_clock.h        |   37 +++++

ptp_clock.h should probably be added to "include/linux/Kbuild".

Wolfgang.
