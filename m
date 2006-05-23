From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 07:38:51 -0700
Message-ID: <20060523073851.39c3b5fe@localhost.localdomain>
References: <44731733.7000204@ti-wmc.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54676 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751344AbWEWOi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 10:38:58 -0400
To: Herman Elfrink <herman.elfrink@ti-wmc.nl>
In-Reply-To: <44731733.7000204@ti-wmc.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> Usage
> =====
> - Load module:
>     modprobe flame [debuglevel=]  [flm_topo_timer=]
>       : debug level, default: 1
>       : topology check timer (in seconds), default: 5
> - Open/close a device with:
>     echo "up   []" > /proc/net/flame/cmd
>     echo "down " > /proc/net/flame/cmd
>       : name of FLAME device, e.g. flm0
>       : comma-separated list of MAC devices (at least one) that are
>       used below the FLAME device. All of these must be up.
>     : comma-separated list of MAC addresses of devices
>       for which traffic should be ignored; each MAC address should
>       be a semicolon-separated list of 6 hex-pairs
> - Get current forwarding info from FLAME:
>     cat /proc/net/flame/fwd
> - Get nodes/cost information from MACINFO:
>     cat /proc/net/macinfo


Use of /proc for an API is no longer desirable. Please rewrite.
