From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] [patch 5/6] [Network namespace] ipv4 isolation
Date: Fri, 9 Jun 2006 20:23:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606092022320.17380@d.namei>
References: <20060609210202.215291000@localhost.localdomain>
 <20060609210631.346330000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:19398 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932601AbWFJAXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 20:23:43 -0400
To: dlezcano@fr.ibm.com
In-Reply-To: <20060609210631.346330000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Jun 2006, dlezcano@fr.ibm.com wrote:

> When an outgoing packet has the loopback destination addres, the
> skbuff is filled with the network namespace. So the loopback packets
> never go outside the namespace. This approach facilitate the migration
> of loopback because identification is done by network namespace and
> not by address. The loopback has been benchmarked by tbench and the
> overhead is roughly 1.5 %

I think you'll need to make it so this code has zero impact when not 
configured.


- James
-- 
James Morris
<jmorris@namei.org>
