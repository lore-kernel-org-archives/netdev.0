From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Tue, 21 Oct 2008 13:15:38 +0200
Message-ID: <48FDB9DA.5020503@redhat.com>
References: <200810151357.m9FDvZqk028829@post.webmailer.de> <20081015225023.GB12337@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: c4p7n@capitanio.org, netdev@vger.kernel.org, kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42438 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482AbYJULPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 07:15:48 -0400
In-Reply-To: <20081015225023.GB12337@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> c4p7n@capitanio.org <c4p7n@capitanio.org> :
>> May be we are reading just by luck zeros and not a random perfectly
>> sane address.
> 
> I would use the attached patches. The former one is mostly Ivan's one
> with some rework of the debug messages. The later checks the eeprom
> for its signature.
> 
> With these patches the driver notices that it can not get an address
> for my 8168b but it works ok with my 8169 after both an hot and a
> cold boot. Interestingly enough, the VPD is not enabled on the 8169
> during the first boot.
> 
> Ivan, can you test them (and fix them afterwards :o) ) ?
No problem found. Both 8168c (GIGA_MAC_VER_20) and 8102el (GIGA_MAC_VER_09)
successfully loads MAC address from EEPROM (from power-off state and also
after reboot).

Ivan
