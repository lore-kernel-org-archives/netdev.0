From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 2/2] tlan: Enable link monitoring
Date: Fri, 16 May 2014 20:59:17 +0200
Message-ID: <201405162059.17456.linux@rainbow-software.org>
References: <1400263230-2599-1-git-send-email-linux@rainbow-software.org> <1400263230-2599-2-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400263230-2599-2-git-send-email-linux@rainbow-software.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 May 2014 20:00:30 Ondrej Zary wrote:
> Enable old link monitoring code and modify it:
>  - control LINK LED
>  - use separate timer so it does not interfere with ACT LED
>  - reset adapter on link loss to restart autonegotiation
>    (required to switch between 10/100 Mbps on OC-2326)

Oops, sorry. This part is broken - the link comes up properly but no packets 
can be transferred then.

-- 
Ondrej Zary
