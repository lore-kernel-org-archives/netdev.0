From: Ben Greear <greearb@candelatech.com>
Subject: Re: Offloading features in VLAN interfaces
Date: Thu, 05 Oct 2006 09:25:39 -0700
Message-ID: <45253203.8050805@candelatech.com>
References: <b54af0b00609291721u16acb2f1ma918adec9b2e782b@mail.gmail.com> <b54af0b00609291725t55ac0a84pf86525ef0a31f44e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yoshio Turner <yoshiotu@hpl.hp.com>,
	"Santos, Jose Renato G" <joserenato.santos@hp.com>,
	"Janakiraman, John" <john.janakiraman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39397 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751674AbWJEQ2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 12:28:36 -0400
To: olivier.crameri@epfl.ch
In-Reply-To: <b54af0b00609291725t55ac0a84pf86525ef0a31f44e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olivier Crameri wrote:
> Same thing but with the patch this time.
Since the VLAN device's features may also change in the handler, 
shouldn't we check and generate a feature-change
event for the VLAN device(s) as well?

Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


