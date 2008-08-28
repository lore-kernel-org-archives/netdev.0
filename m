From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Thu, 28 Aug 2008 16:54:32 +0400
Message-ID: <48B6A008.9080907@openvz.org>
References: <48B5815D.4010005@openvz.org> <48B589B5.7050303@cosmosbay.com> <48B68827.2060105@openvz.org> <48B69F48.5050308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41314 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbYH1Myo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 08:54:44 -0400
In-Reply-To: <48B69F48.5050308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sometime I wonder if a *global* pointer ('current' pointer for example 
> is not passed to every kernel function that want access to current
> struture) would save many kbytes in vmlinux text. This way, !CONFIG_NET_NS 
> overhead would completely vanish.

:) I'm glad to hear, that we're not alone with such a view of how
this have to work. We at OpenVZ proposed the current_net macro from
the very beginning, but other netns developers decided to go the other
way :(

> Oh well...

Oh well, indeed...
