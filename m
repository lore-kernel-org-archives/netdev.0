From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: extra layer below inet layer.
Date: Wed, 6 Jun 2007 22:25:11 -0700
Message-ID: <20070606222511.714973f8@localhost.localdomain>
References: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tej Parkash" <tejparkash.d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49395 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756570AbXFGFZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 01:25:21 -0400
In-Reply-To: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jun 2007 10:10:44 +0530
"Tej Parkash" <tejparkash.d@gmail.com> wrote:

> hi
> 
> i just want to have something like tcp layer sitting below inet layer.
> so that i can directly offload everything to NIC
> and i want it to be placed dynamically. so depending on the nic i can
> offload the feature or can make it normal flow.
> i.e. both layer should exist and normal functionality should not break.
>
NIC protocol offloading is a contentious subject since it bypasses
all the security and restricts usefulness of the device for VLAN's,
bonding, bridging, etc.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
